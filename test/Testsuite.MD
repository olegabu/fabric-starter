# Hyperledger Fabric Starter Testing Suite
The Hyperledger Fabric Starter Testing Suite is a basic set of scripts and libraries designed to verify the correctnes on Hyperledger Fabric network installation using Fabric Starter, as well as the essential functionality of the Network deployed.

The Test Suite checks the operation of Fabric Network deployed locally or in docker-machine multihost environment. 
## Features and functions tested

* Hyperledger containers for orderer and organizations are up and running
* Network is up and running
* Service channels were created 
* New channels can be created in every organization
* Organizations with given permissions can join certain channels
* New chaincodes can be installed and instantiated in the channel

## Test Suite components
The Fabric starter Test sute components could be found in the ```./test``` folder of the Fabric Starter package.
```bash
test
├──  api                        #API action cripts folder
├──  cli                        #CLI action scripts folder
├──  verify                     #Veirfication scrips folder
├── common-test-env.sh          #Common testing environment variables and functions
├── local-test-env.sh           #Source script for testing the locally installed Network
├── lib-scenario.sh             #Testing scenario vars and functions
├── libs.sh                     #General Test Suite unctions
├── parse-common-params.sh      #Common parameters parsing library
├── run_scenario.sh             #Sample testing scenario script
├── Testsuite.MD                #This doc
└── vbox-test-env.sh            #Source script for testing the multihost Network deployment
```

## Scenarios
Testing scenarios utilize tipical action and verification scripts to perform some basic operations in the Network and to verify the results and the performance of the Hyperledger Fabric Network deployment. The sample scenario included demonstrates the testing process in several basic steps.

## Prerequisites
While running the sample scenario we assume that the Network with orderer and two organizations has been deployed locally or on two remote machines by mean of standard Fabric starter deployment scripts. Though any custom-tailored Network could be tested. You should have at hand some basic information on your deployment before running tests, e.g. organization names, domain or docker-machine names. 

## Running tests

So the testing sequence is the following.
Decide what type of deployment (local or remote) you are going to test. For local instalation first source the local-test-env.sh file. The multihost VirtualBox deployment requires the vbox-test-env.sh to be sourced, e.g.:
```
source local-test-env.sh example.net first_org second_org   
```
for local Network deloyment or 
```
source vbox-test-env.sh example.net first_org second_org   
```
for multihost deployment. Provide the domain, the first organization and the second organization as the arguments to the script. Now you are ready to run the testing scenario.

## Running scenario

The tipical way to run the testing scenario is to launch the scenario scipt in the following way:
```bash
DEBUG=false ./run_scenario.sh cli,api first_org second_org 
```
Here you should provide the Fabric Starter interface types used to run basic operations in the network (cli for command-line and api for REST API interface, one or both, comma-separated), and names of two organizations participating in the testing procedure.

The DEBUG environment variabe being set to 'true' makes the scenario print all the debug information of the Fabric and the Test Suite both on your terminal and to the log file (fs_network_test.log). While the DEBUG var being set to 'false' (which is the default), only the brief details are printed on your terminal but all the debug data are still stored in the log file.

As a result you will get the output with operations performed (and also their exit codes), as well as the summary table containig the description of all the tests, exit codes and the runtime duration.

## Writing custom scenarios
TODO

========================================================




В состав Hypelredger Fabric Starter входит скрипт **network-create-local.sh**, который позволяет развернуть HLF-сеть из нескольких организаций на локальной машине, с HLF-сервисами, запущенными в Docker-контейнерах.
Для создания сети из службы ордерера и служб организаций **org1** и **org2** в домене example.com запустите команду:  

 ```bash
network-create-local.sh org1 org2  
```

В результате выполнения скрипта будет развернут и запущен набор docker-контейнеров, необходимых для функционирования сети.
  
Кроме установки скрипт создает консорциум **SampleConsortium** из двух организаций **org1** и **org2**, создаент канал **common** для этих организаций, а также устанавливает чейн-код **reference** (написанный на node.js).  

## Предварительные требования

Для начала работы в теущей сети необходимо выполнить следующие требования.

* Наличие развернутой сети Hyperledger Fabric (локально, либо на нескольких узлах (multihost-конфигурация)). Подробное описание развертывания сетей содержится в документах:

  * [Сеть из одной организации](docs/network-one-org.md)
  * [Сеть из трех организаций](network-three-org.md)
  * [Сеть из нескольких организаций на разных хостах](multihost.md)

* Команды в CLI-выполняются в CLI-контейнерах соотвтетсвующих организаций или ордереров, поскольку в них уже настроены нужные переменные системного окружения.

В дальнейшем мы будем предполагать, что название первой организации содержится в переменной ORG, а домена — в переменной DOMAIN. В начале работы выполните экспорт переменных:

```bash
export ORG='org1' DOMAIN='example.com'
```

В тестовой сети приняты такие названия, но в промышленном варианте организации и ломены будут называться по-другому, например:

```bash
export ORG='firstbank' DOMAIN='blockchain.net'
```

* Команды Hyperledger Fabric Starter, которые выполняются в cli-контейнерах, запускаются через docker ```docker exec -it cli.$ORG.$DOMAIN```, в параметрах передаем команду для выполнения в контейнере, поэтому все команды имеют вид ```docker exec -it cli.$ORG.$DOMAIN [command]```, где $ORG.$DOMAIN — проверяемая организация.
Для контейнера ордерера организацию указывать не нужно: ```docker exec -it cli.$DOMAIN [command]```.

### Проверка корректного развертывания сети — получаем текущий статус

* Проверка наличия контейнеров
* Консорциум
* Проверка наличия каналов
* Проверка наличия всех организаций (в канале common или др.)
* Проверка чейнкода DNS и данных, сохраненных им в канале common

### Проверка функционирования (работы) сети

* Запуск новой организации
* Создание нового канала
* Добавление организаций в консорциум
* Добавление организаций в канал
* Проверка join
* install/instantiate/invoke/query chaincode
* curl
* Проверка на UI

### Extended-сценарий

* Реализаци нестандартной endoresment policy

## Проверка корректного развертывания сети — получаем текущий статус

### Проверка наличия контейнеров

Полсе развертывания сети необходимо проверить наличие контейнеров служб Hyperledger Fabric.
Выполните команду:

```bash
docker ps
```
чтобы посмотреть на запущенные контейнеры.

Для **ордерера** должны быть запущены конейнеры:

* **cli**.$DOMAIN
* **orderer**.$DOMAIN
* **www**.$DOMAIN

Для **организации** долдны быть запущены контейнерами с именами:

* **api**.$ORG.$DOMAIN
* **ca**.$ORG.$DOMAIN
* **cli**.$ORG.$DOMAIN
* **couchdb**.$ORG.$DOMAIN (если используется в конфигурации сети)
* **peer0**.$ORG.$DOMAIN
* **www**.$ORG.$DOMAIN

полученная информация включает имена контейнеров, статус и открытые сетевые порты.

Для того, чтобы посмотреть только имена контейнеров, воспользуйтесь командой

```docker ps --format "table {{.Names}}" | tail -n+2 | sort```

на хосте, где должны быть запущены соотвтетсвующие контейнеры.

Если вас интересуют контейнеры только одной организации, отфильтруйте выаод по ее имени:

```export ORG='org1';  docker ps --format "table {{.Names}}" | grep $ORG | tail -n+2 | sort```

### Консорциум

Если организации являются членами одного консорциума (consortium), они могут быть подключены к общему каналу (channel).





Команды выполняются внутри docker-конт cli. (настроено окружение) docker exec -it cli.$ORG.$DOMAIN в параметрах передаем команду для выполнения в контейнере, поэтому все команды имеют вид docker exec -it cli.$ORG.$DOMAIN **Команда**
 $ORG.$DOMAIN -- проверяемая организация 
 
### Проверка наличия каналов 

Экспортируем переменные (переместить в начало!):
export ORG='org1' DOMAIN='example.com'
Проверим, создан ли канал common и подключены ли к нему организации org1 и org2
docker exec -it cli.$ORG.$DOMAIN bash -c 'source container-scripts/lib/container-lib.sh; peer channel list -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS'

Ожидаемый результат выполнения:
```
_Channels peers has joined: _ _**common**_
```
То же для **org2:**  

export ORG='org2' а остальное -- такое же.

----
```bash
----export ORG='org2' DOMAIN='example.com'  
-----docker exec -it cli.$ORG.$DOMAIN bash -c 'source container-scripts/lib/container-lib.sh; peer channel list -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS'
```

#### Консорциум

Наоборот!  Для подключения организаций к общему каналу необходимо, чтобы они были членами одного консорциума. 
-----Если канал создан (common) и обе организации к нему подключены, то это означает, что скрипт установки добавил эти организации в консорциум. 

Проверяем: состоянт в консорциуме организации состоят, выполните команды
  
УДАЛИТЬ:
смотрите json, jq -- для быстрого ппросмотра
fetch консорциума в канале system-config-channel выполняется CLI ордерера!

  Для организации **org1**:export ORG='org1' DOMAIN='example.com'docker exec -it cli.**$ORG**.**$DOMAIN** bash -c 'source container-scripts/lib/container-lib.sh; peer channel fetch config /dev/stdout -c system-config-channel -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS 2&gt;/dev/null&gt; common_'**$ORG****'**_test.pb' docker exec -it cli.**$ORG.****$DOMAIN** bash -c 'source container-scripts/lib/container-lib.sh;  configtxlator proto_decode --type "common.Block" --input=common_'**$ORG**'_test.pb' &gt; common_**$****{****ORG****}**_test.json  
jq .data.data[0].payload.data.config.channel_group.values.Consortium.value.name ./common_**${ORG}**_test.jsonОжидаемый результат выполнения:_**"SampleConsortium"**_То же выполните для второй организации, заменив имя организации:  
  
export ORG='org2' DOMAIN='example.com'

#### Чейнкод DNS

Запрос текущей информации ./chaincode-query.sh

#### Создание канала

Задайте имя канала, название организации и домена:export TEST_CHANNEL_NAME='testchannel123'export ORG='org1' DOMAIN='example.com'Выполните комаду:  
./channel-create.sh ${TEST_CHANNEL_NAME}

Проверим, создался ли канал:  
  
 Три отдельных команды, объяснить, для чего
 
  
docker exec cli.$ORG.$DOMAIN /bin/bash -c \'source container-scripts/lib/container-lib.sh; \peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS -c '$TEST_CHANNEL_NAME' $ORDERER_TLSCA_CERT_OPTS 2&gt;/dev/null | \configtxlator  proto_decode --type "common.Block" | \jq .data.data[0].payload.data.last_update.payload.header.channel_header.channel_id'

Ожидаемый результат выполнения:  

"testchannel123"Выполните команду, добавляющую в канал вторую организацию:  
  
./channel-add-org.sh ${TEST_CHANNEL_NAME} org2Проверим, добавлена ли организация в канал:  
  
docker exec cli.$ORG.$DOMAIN \/bin/bash -c 'source container-scripts/lib/container-lib.sh; \peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS \-c '$TEST_CHANNEL_NAME' $ORDERER_TLSCA_CERT_OPTS 2&gt;/dev/null | \configtxlator  proto_decode --type common.Block' | \jq .data.data[0].payload.data.config.channel_group.groups.Application.groups.org2.values.MSP.value.config.name  
Ожидаемый результат выполнения:  
_**"org2"**_

#### 
Подключение организаций к каналу

Добавим в канал обе организации:  
  
```bash
export PEER0_PORT=7051 ORG='org1' DOMAIN='example.com'  
./channel-join.sh ${TEST_CHANNEL_NAME}
```

Проверим, добавлена ли первая организация:
```bash
docker exec cli.$ORG.$DOMAIN /bin/bash -c \'source container-scripts/lib/container-lib.sh; \peer channel list -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS'
```
Ожидаемый результат выполнения:  
  
_**Channels peers has joined: **__**common**__**testchannel123  **_Выполняем то же для второй организации:  

```bash  
export PEER0_PORT=8051 ORG='org2' DOMAIN='example.com'  
./channel-join.sh ${TEST_CHANNEL_NAME}  
```  
Проверим, добавлена ли вторая организация:
```bash
docker exec cli.$ORG.$DOMAIN /bin/bash -c \'source container-scripts/lib/container-lib.sh; \peer channel list -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS'
```
Ожидаемый результат выполнения:  

_**Channels peers has joined: **__**common**__**testchannel123**_

#### Чейн-код (инстанциация)

Инстанциируем на канале testchannel123 чейн-код reference,который был установлен при интсалляции сети.export PEER0_PORT=7051 ORG='org1' DOMAIN='example.com' ./chaincode-instantiate.sh ${TEST_CHANNEL_NAME} referenceПроверим, доступен ли чейн-код для обоих организаций, подключенных к каналу testchannel123:  
```bash  
docker exec cli.$ORG.$DOMAIN /bin/bash -c \'source container-scripts/lib/container-lib.sh; \peer chaincode list --instantiated -C '$TEST_CHANNEL_NAME' -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS'
```
Ожидаемый результат выполнения:
_Get instantiated chaincodes on channel testchannel123:__Name: **reference**, Version: 1.0, Path: /opt/chaincode/node/reference, Escc: escc, Vscc: vscc_

Проверим то же для второй организации:   
```bash
export PEER0_PORT=8051 ORG='org2' DOMAIN='example.com' 
docker exec cli.$ORG.$DOMAIN /bin/bash -c \
'source container-scripts/lib/container-lib.sh; \
peer chaincode list --instantiated -C '$TEST_CHANNEL_NAME' -o $ORDERER_ADDRESS $ORDERER_TLSCA_CERT_OPTS'  
```  
Ожидаемый результат выполнения:
_Get instantiated chaincodes on channel testchannel123:__Name: **reference**, Version: 1.0, Path: /opt/chaincode/node/reference, Escc: escc, Vscc: vscc_

#### Чейн-код (проверка исполнения)

Проверим, как исполняется установленный чейн-код reference. Для этого запишем в первой организации в леджер праметр  _testchannel123_ со значением_testchannel123 _ а
затем, через небольшой промежуток времени прочтем его во второй органнизации:
```bash
PEER0_PORT=7051
ORG=org1 ./chaincode-invoke.sh ${TEST_CHANNEL_NAME} **reference**
'["put","'${TEST_CHANNEL_NAME}'","'${TEST_CHANNEL_NAME}'"]'

sleep
5

PEER0_PORT=8051
ORG=org2 ./chaincode-query.sh ${TEST_CHANNEL_NAME} **reference** '["get","'${TEST_CHANNEL_NAME}'"]'   
```  
Через некоторое время вы должны получить следующий результат:  
  
_Execute: docker-compose -f docker-compose.yaml    run --no-deps --rm cli.peer bash -c container-scripts/network/chaincode-query.sh testchannel123 reference '["get","testchannel123"]'_
_CORE_PEER_ADDRESS=peer0.org2.example.com:8051 peer chaincode query -n reference -C testchannel123 -c '{"Args":["get","testchannel123"]}'_

_**testchannel123**_
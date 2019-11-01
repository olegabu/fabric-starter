1. Build `fabric-tools-extedned` and `fabric-starter-rest` images:
- in folder `fabric-starter`
    - run docker build:  
```bash
docker build -t olegabu/fabric-tools-extended -f fabric-tools-extended/Dockerfile .
```
- in folder `fabric-starter-rest`
    - run docker build:  
```bash
docker build -t olegabu/fabric-starter-rest .
```

2. Start `orderer`:
```bash
./clean.sh
docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-ports.yaml up -d
``` 

3. Start `org1`:
```bash
COMPOSE_PROJECT_NAME=org1 ORG=org1 API_PORT=4000 docker-compose -f docker-compose.yaml -f docker-compose-api-port.yaml up -d
``` 

4.  Start `org2`:
   ```bash
   BOOTSTRAP_IP=172.17.0.1 COMPOSE_PROJECT_NAME=org2 ORG=org API_PORT=4001 docker-compose -f docker-compose.yaml -f docker-compose-api-port.yaml up -d
   ```
172.17.0.1 is docker's `bridge` network gateway address. Same on all machines.

5. Go to `Org1` Web Admin panel. Wait for channel `common` is created and `dns` chaincode is instantiated.   

6. Press the `plus` button. Select a task and  `Save task settings` (visually nothing happens)

7. Go to Org2 web admin panel. Organization `org1` button appears. Press the small plus button.

8. Select Scenario tab, `Join Me to Existing channel`   

9. Set `apiPort` to 3000.

10. Press `Launch`. Wait for channel `common` appears.
# DNS Configuration

If we are going to add new organizations dynamically their IP addresses have to be provided for all existing containers
in the blockchain network.

In order to pass the information about IPs we can use a internal DNS service (serving only for the blockchain network being deployed)
and configure Docker to use this internal DNS.

There are two options for configuring DNS service:
- Using host system DNS service
- Using DNS-in-docker solution (TBD)


## Using system DNS service (Dnsmasq).

[Dnsmasq](https://en.wikipedia.org/wiki/Dnsmasq) is famous Linux DNS forwarder used by default in many Linux distributions.
But in Ubuntu 18.04 the other name resolver is used by default `systemd-resolved`.

`Systemd-resolved` doesn't allow Docker to use the host's DNS. So the solution is to install `Dnsmasq` along with the default resolver
and use `Dnsmasq` only for the blockchain network domain.


## Install Dnsmasq

For Ubuntu:
```bash
sudo apt install dnsmasq
```

After installing  it tries to start `dnsmasq`.

In Ubuntu 18.04 `dnsmasq` fails to start because of conflict on port 53 (dns-resolve port):

```
nov 14 19:16:06 ubuntubcs systemd[1]: Starting dnsmasq - A lightweight DHCP and caching DNS server...
nov 14 19:16:06 ubuntubcs dnsmasq[16226]: dnsmasq: syntax check OK.
nov 14 19:16:06 ubuntubcs dnsmasq[16235]: dnsmasq: failed to create listening socket for port 53: Адрес уже используется
nov 14 19:16:06 ubuntubcs systemd[1]: dnsmasq.service: Control process exited, code=exited status=2
nov 14 19:16:06 ubuntubcs dnsmasq[16235]: failed to create listening socket for port 53: Address already in use
nov 14 19:16:06 ubuntubcs systemd[1]: dnsmasq.service: Failed with result 'exit-code'.
nov 14 19:16:06 ubuntubcs dnsmasq[16235]: FAILED to start up
nov 14 19:16:06 ubuntubcs systemd[1]: Failed to start dnsmasq - A lightweight DHCP and caching DNS server.
Processing triggers for systemd (237-3ubuntu10.6) ...
Processing triggers for ureadahead (0.100.0-20) ...
```


To fix this edit the `dnsmasq` configuration and activate bind-interfaces parameter:

sudo nano /etc/dnsmasq.conf

Uncomment line with option *bind-interfaces*:
```
...
# On systems which support it, dnsmasq binds the wildcard address,
# even when it is listening on only some interfaces. It then discards
# requests that it shouldn't reply to. This has the advantage of
# working even when interfaces come and go and change address. If you
# want dnsmasq to really bind only the interfaces it is listening on,
# uncomment this option. About the only time you may need this is when
# running another nameserver on the same machine.
bind-interfaces
...
```

and restart `dnsmasq`:
```
sudo systemctl restart dnsmasq.service
```

Now it starts without errors.


## Configure Docker to use host's dnsmasq service:
Create file /etc/docker/daemon.json and add **dns** configuration:

Find out the gateway address used in docker sub-network:
```
ip addr | grep docker0
```

*Result*:
  **docker0**: <BROADCAST,MULTICAST,UP,LOWER_UP>
  ...
    inet **`172.17.0.1`**/16




The address should be added to the following configuration files:

```
sudo nano /etc/docker/daemon.json
```


Add configuration (use the address reported above):

```
{
    "dns": ["172.17.0.1", "172.18.0.1", "8.8.8.8", "8.8.4.4"]
}
```


After starting blockchain network docker can create extra bridge networks:

**br-4d38cc4d0184**: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:66:1d:95:b5 brd ff:ff:ff:ff:ff:ff
    inet **`172.18.0.1`**/16 brd 172.18.255.255 scope global br-4d38cc4d0184
       valid_lft forever preferred_lft forever

They all should be added to the docker configuration file:
```
{
    "dns": ["172.17.0.1", "172.18.0.1", "172.19.0.1", "172.20.0.1", "172.21.0.1", "8.8.8.8", "8.8.4.4"]
}
```


Then restart Docker engine and restart containers if networ had already been started:
```
sudo service docker restart

docker start $(docker ps -aq)
```


## Configure dnsmasq to accept requests from docker sub-network

By default `dnsmasq` accepts dns-requests only from localhost (127.0.0.1) clients.
To allow it accepting requests from docker containers adjust `docker-bridge.conf` file:

```
sudo mkdir -p /etc/NetworkManager/dnsmasq.d
sudo nano /etc/NetworkManager/dnsmasq.d/docker-bridge.conf
```

Add the same addresses found out in previous section:

```
listen-address=172.17.0.1
listen-address=172.18.0.1
```


Restart network manager:
```
sudo service dnsmasq restart
```



## Configure host addresses of other organizations

Adjust /etc/hosts file on the host.
```
sudo nano /etc/hosts
```

Add:
```
10.50.154.2 orderer.example.com www.example.com

10.50.154.4 peer0.org1.example.com peer1.org1.example.com www.org1.example.com
```

The IP addresses of the host names will be immediately resolvable in containers:
```
docker run --rm hyperledger/fabric-tools bash -c "wget peer0.org1.example.com"
```

--2018-11-14 16:47:40--  `http://peer0.org1.example.com/`
Resolving peer0.org1.example.com (peer0.org1.example.com)... `10.50.154.4`


# Deploying network along with DNS service

If you use DNS service (not Swarm) then nodes must be started exposing
Fabric related ports in order to make them accessible through external network (Internet):

Orderer:
```bash
docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-ports.yaml up
```

Nodes:
```bash
docker-compose -f docker-compose.yaml -f ports.yaml up
```

# Configuration with master DNS server

A central or master DNS server can be configured for a particular blockchain network.
This allows all organizations to avoid reconfiguration of their `/etc/hosts` file individually and use the central server DNS configuration automatically.

To configure organizations' (child) DNS services (after performing the previous configuration steps) adjust the `/etc/dnsmasq.conf` and specify the DNS server address:

```
server=x.x.x.x
```

The master server DNS server doesn't need an additional configuring except of the steps described in the previous sections.
Now IP addresses of newly added organizations have to be specified only in master's `/etc/hosts` file. Restart of `dnsmasq` is required after that.

Note, port 53 has to be enabled on firewalls both at the child and the master servers in order to allow dns-requests.


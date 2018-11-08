# Swarm network

To connect nodes through a swarm network we define one of the node as a *Swarm Manager* node.
This is usually th ordereer node, but not necessary.
The other nodes will be *worker* nodes and should join to the manager.

Start docker swarm on `orderer` machine. Replace ip address `192.168.99.100` with the actual ip of the remote host interface.
```bash
docker swarm init --advertise-addr 192.168.99.100
```


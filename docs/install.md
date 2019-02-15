# Install

Install prerequisites: `docker >=18.06.1` and `docker-compose >=1.22.0`.

## Docker
### Ubuntu 18

```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt-get install docker-ce

sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# add yourself to the docker group and re-login
sudo usermod -aG docker ${USER}
```

### Mac OSX

Install `docker ce` and `docker compose` by [brew](https://brew.sh/).
```bash
brew install docker 
```


## Docker-compose
### Ubuntu 18
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Mac OSX
See https://docs.docker.com/docker-for-mac/install/

# ARD web app


## Install and build

Install prerequisites: Node.js. This example is for Ubuntu:
```bash
sudo apt install nodejs npm
```

Install Aurelia CLI
```bash
npm install aurelia-cli -g
```

Build
```bash
npm install && au build
```

## Development

Run in development
```bash
au run --watch
```
Your web application served by `au run` in development at [http://localhost:9000](http://localhost:9000) will connect
to the API server of org [http://localhost:4000](http://localhost:4000).




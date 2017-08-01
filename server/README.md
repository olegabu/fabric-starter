
Hyperledger Fabric API
======================


Environment
-----------

* `PORT` - api/web interface port (default is `4000`)
* `ORG` - organization id. No default value, you have to set it explicitly
* `CONFIG_DIR` - ledger config dir (should have `network-config.json`)
* `WEB_DIR` - location of web application (default is `www`)


Launch
------
Api web-interface become available on `http://localhost:4000` after launching:

```
  npm install
  ORG=org1 npm start
  # or: ORG=org2 npm start
```


Dev environment
---------------
```
ORG=org1 npm run dev

```

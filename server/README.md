
Hyperledger Fabric API
======================


Environment
-----------

* `PORT` - api/web interface port (default is `4000`)
* `ORG` - organization id. No default value, you have to set it explicitly
* `CONFIG_FILE` - ledger config file (default is `../artifacts/network-config.json`)
* `WEB_DIR` - location of web application (default is `www`)
* `MIDDLEWARE_CONFIG_FILE` - middleware map file (default is `../middleware/map.json`)


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



Known issues
------------

* peer ID should be started with 'peer' word (specified in `network-config.json`).  
  
  RIGHT:
```
   ...
        "org1": {
			...
			"peer1": { ... },
			"peer2.example.com": { ... },
			"peer": { ... },
		},
   ...
```

  WRONG:
```
   ...
        "org1": {
			...
			"n1.peer": { ... },
			"host2.example.com": { ... },
		},
   ...
```

* orderer should be named `"orderer"`. No options, you cannot rename it.

* endpoints `/channels/<channelName>/config` and `/genesis` are not work properly

* chaincode instantiate works with `peer1` exactly. no options here

* admin UI uses `peer1` to get common info
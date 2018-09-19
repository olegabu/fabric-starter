const fs = require('fs');

const myorg = process.env.ORG || 'org1';
const domain = process.env.DOMAIN || 'example.com';
const cryptoConfigDir = process.env.CRYPTO_CONFIG_DIR || '../fabric-starter/crypto-config';
const enrollId = process.env.ENROLL_ID || 'admin';
const enrollSecret = process.env.ENROLL_SECRET || 'adminpw';
const orgs = JSON.parse(process.env.ORGS || '{"org1":"localhost:7051"}' );// `peer0.${org}.${domain}:7051` inside docker
const cas = JSON.parse(process.env.CAS || '{"org1":"localhost:7054"}' );

const t = {
  name: 'Network',
  version: '1.0',
};

function addOrg(t, org) {
  if(!t.organizations) {
    t.organizations = {};
  }
  t.organizations[org] = {
    // mspid: `${org}MSP`,
    mspid: `${org}`,
    peers: [
      `peer0.${org}.${domain}`
    ]
  };

  if(org === myorg) {
    const keystorePath = `${cryptoConfigDir}/peerOrganizations/${org}.${domain}/users/Admin@${org}.${domain}/msp/keystore`;
    const keystoreFiles = fs.readdirSync(keystorePath);
    const keyPath = `${keystorePath}/${keystoreFiles[0]}`;

    t.organizations[org].certificateAuthorities = [org];
    t.organizations[org].adminPrivateKey = {
      path: keyPath
    };
    t.organizations[org].signedCert = {
      path: `${cryptoConfigDir}/peerOrganizations/${org}.${domain}/users/Admin@${org}.${domain}/msp/signcerts/Admin@${org}.${domain}-cert.pem`
    };
  }
}

function addPeer(t, org, i, peerAddress) {
  if(!t.peers) {
    t.peers = {};
  }
  t.peers[`peer${i}.${org}.${domain}`] = {
    url: `grpcs://${peerAddress}`,
    grpcOptions: {
       'ssl-target-name-override': `peer${i}.${org}.${domain}`,
      //'ssl-target-name-override': 'localhost',
      'grpc.keepalive_time_ms': 600000
    },
    tlsCACerts: {
      path: `${cryptoConfigDir}/peerOrganizations/${org}.${domain}/peers/peer${i}.${org}.${domain}/msp/tlscacerts/tlsca.${org}.${domain}-cert.pem`
    }
  };
}

function addCA(t, org, caAddress) {
  if(!t.certificateAuthorities) {
    t.certificateAuthorities = {};
  }

  t.certificateAuthorities[org] = {
    url: `https://${caAddress}`,
    httpOptions: {
      verify: false
    },
    tlsCACerts: {
      path: `${cryptoConfigDir}/peerOrganizations/${org}.${domain}/ca/ca.${org}.${domain}-cert.pem`
    },
    registrar: [
      {
        enrollId: enrollId,
        enrollSecret: enrollSecret
      }
    ],
    caName: 'default'
  };
}

module.exports = function () {
  t.client = {
    organization: myorg,
    credentialStore: {
      path: `hfc-kvs/${myorg}`,
      cryptoStore: {
        path: `hfc-cvs/${myorg}`
      }
    }
  };

  Object.keys(orgs).forEach(k => {
    addOrg(t, k);
    addPeer(t, k, 0, orgs[k]);
  });

  Object.keys(cas).forEach(k => {
    addCA(t, k, cas[k]);
  });

  return t;
};

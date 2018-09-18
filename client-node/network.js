const fs = require('fs');

const org = process.env.ORG || 'org1';
const domain = process.env.DOMAIN || 'example.com';
const cryptoConfigDir = process.env.CRYPTO_CONFIG_DIR || '../fabric-starter/crypto-config';
const enrollId = process.env.ENROLL_ID || 'admin';
const enrollSecret = process.env.ENROLL_SECRET || 'adminpw';
const peerAddress = process.env.PEER_ADDRESS || 'localhost:7051'; // || `peer0.${org}.${domain}:7051` inside docker
const caAddress = process.env.CA_ADDRESS || 'localhost:7054'; // || `ca.${org}.${domain}:7054`

const t = {
  name: 'Network',
  version: '1.0',
};

function addOrg(t, org) {
  const keystorePath = `${cryptoConfigDir}/peerOrganizations/${org}.${domain}/users/Admin@${org}.${domain}/msp/keystore`;
  const keystoreFiles = fs.readdirSync(keystorePath);
  const keyPath = `${keystorePath}/${keystoreFiles[0]}`;
  console.log('keyPath', keyPath);

  if(!t.organizations) {
    t.organizations = {};
  }
  t.organizations[org] = {
    mspid: `${org}MSP`,
    // mspid: `${org}`,
    peers: [
      `peer0.${org}.${domain}`
    ],
    certificateAuthorities: [
      org
    ],
    adminPrivateKey: {
      path: keyPath
    },
    signedCert: {
      path: `${cryptoConfigDir}/peerOrganizations/${org}.${domain}/users/Admin@${org}.${domain}/msp/signcerts/Admin@${org}.${domain}-cert.pem`
    }
  };
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
    organization: org,
    credentialStore: {
      path: `hfc-kvs/${org}`,
      cryptoStore: {
        path: `hfc-cvs/${org}`
      }
    }
  };

  addOrg(t, org);
  addPeer(t, org, 0, peerAddress);
  addCA(t, org, caAddress);

  return t;
};

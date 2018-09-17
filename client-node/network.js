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
  t.organizations = {};
  t.organizations[org] = {
    mspid: `${org}MSP`,
    peers: [
      `peer0.${org}.${domain}`
    ],
    certificateAuthorities: [
      org
    ],
    adminPrivateKey: {
      path: `${cryptoConfigDir}/peerOrganizations/${org}.${domain}/users/Admin@${org}.${domain}/msp/keystore/sk.pem`
    },
    signedCert: {
      path: `${cryptoConfigDir}/peerOrganizations/${org}.${domain}/users/Admin@${org}.${domain}/msp/signcerts/Admin@${org}.${domain}-cert.pem`
    }
  };
  t.peers = {};
  t.peers[`peer0.${org}.${domain}`] = {
    url: `grpcs://${peerAddress}`,
    grpcOptions: {
      'ssl-target-name-override': `peer0.${org}.${domain}`,
      'grpc.keepalive_time_ms': 600000
    },
    tlsCACerts: {
      path: `${cryptoConfigDir}/peerOrganizations/${org}.${domain}/peers/peer0.${org}.${domain}/msp/tlscacerts/tlsca.${org}.${domain}-cert.pem`
    }
  };
  t.certificateAuthorities = {};
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

  return t;
};

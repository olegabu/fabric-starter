window.disableThemeSettings = true;
angular.module('config', [])
.constant('cfg', 
    {
  endpoint: 'http://vp1.altoros.com:7050/chaincode',
  secureContext: 'user_type1_deadbeef',
  chaincodeID: "395026cb60bdb363672abfe16b56c3d165a438f1063ec5d3a9a067daec776c7b762fd3ed3f5c2a6ce5fb5468873a293b44026119f89dce8a3ea42648c8c59dcd",
//  users: [{id: 'issuer0', role: 'issuer', endpoint:'http://localhost:7050/chaincode'},
//          {id: 'issuer1', role: 'issuer', endpoint:'http://localhost:7050/chaincode'},
//          {id: 'investor0', role: 'investor', endpoint:'http://localhost:7050/chaincode'},
//          {id: 'investor1', role: 'investor', endpoint:'http://localhost:7050/chaincode'},
//          {id: 'auditor0', role: 'auditor', endpoint:'http://localhost:7050/chaincode'}],
  users: [{id: 'issuer0', role: 'issuer', endpoint:'http://vp1.altoros.com:7050/chaincode'},
          {id: 'issuer1', role: 'issuer', endpoint:'http://vp1.altoros.com:7050/chaincode'},
          {id: 'investor0', role: 'investor', endpoint:'http://vp2.altoros.com:7050/chaincode'},
          {id: 'investor1', role: 'investor', endpoint:'http://vp2.altoros.com:7050/chaincode'},
          {id: 'auditor0', role: 'auditor', endpoint:'http://vp3.altoros.com:7050/chaincode'}],
  triggers: ['hurricane 2 FL', 'earthquake 5 CA'],
  bonds: [{
            id: 'issuer0.2017.6.13.600',
            issuerId: 'issuer0',
            principal: 500000,
            term: 12,
            maturityDate: '2017.6.13',
            rate: 600,
            trigger: 'hurricane 2 FL',
            state: 'offer'
          }],
  contracts: [{
            id: 'issuer0.2017.6.13.600.0',
            issuerId: 'issuer0',
            bondId: 'issuer0.2017.6.13.600',
            ownerId: 'issuer0',
            couponsPaid: 0,
            state: 'offer'
          },
          {
            id: 'issuer0.2017.6.13.600.1',
            issuerId: 'issuer0',
            bondId: 'issuer0.2017.6.13.600',
            ownerId: 'issuer0',
            couponsPaid: 0,
            state: 'offer'
          },
          {
            id: 'issuer0.2017.6.13.600.2',
            issuerId: 'issuer0',
            bondId: 'issuer0.2017.6.13.600',
            ownerId: 'issuer0',
            couponsPaid: 0,
            state: 'offer'
          },
          {
            id: 'issuer0.2017.6.13.600.3',
            issuerId: 'issuer0',
            bondId: 'issuer0.2017.6.13.600',
            ownerId: 'issuer0',
            couponsPaid: 0,
            state: 'offer'
          },
          {
            id: 'issuer0.2017.6.13.600.4',
            issuerId: 'issuer0',
            bondId: 'issuer0.2017.6.13.600',
            ownerId: 'issuer0',
            couponsPaid: 0,
            state: 'offer'
          }],
    trades: [{
            id: 1000,
            contractId: 'issuer0.2017.6.13.600.0',
            sellerId: 'issuer0',
            price: 100,
            state: 'offer'
          },
          {
            id: 1001,
            contractId: 'issuer0.2017.6.13.600.1',
            sellerId: 'issuer0',
            price: 100,
            state: 'offer'
          },
          {
            id: 1002,
            contractId: 'issuer0.2017.6.13.600.2',
            sellerId: 'issuer0',
            price: 100,
            state: 'offer'
          },
          {
            id: 1003,
            contractId: 'issuer0.2017.6.13.600.3',
            sellerId: 'issuer0',
            price: 100,
            state: 'offer'
          },
          {
            id: 1004,
            contractId: 'issuer0.2017.6.13.600.4',
            sellerId: 'issuer0',
            price: 100,
            state: 'offer'
          }]
    }
);

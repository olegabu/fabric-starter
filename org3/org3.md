# Adding new organisation to existing network

This document describes scenarios of adding new organisation to an existing
network without recreating the network.

Limitations:

- based on `first-network` example not `network.sh`
- scripts are intended for manual execution as running commands from different
  containers and under different orgs is not yet automated. Please follow
  instructions in comments

## Channel with 3 orgs

`file: org3.sh`

Two organisations, org1 and org2, have created the network and a channel
`mychannel`. Scenario adds `org3` to the network and grants `org3` write access
to the `mychannel`.

## Channel with 2 orgs

`file: org3_new_channel.sh` 

This scenario depends on the previous one. It assumes that `org3` has all crypto material 
generated, peer started and joined to `mychannel`.

Now existing org `org1` and new org `org3` wants to create a new channel without
`org2`. `org1` creates a channel `newchan` where it is the only member. Then it creates
and sends channel update transation that adds `org3` to `newchan`. This transaction does
not require signing as `org1` is the only member of the channel consortium. Finally, `org3`
peer joins `newchan` and verifies it can invoke transations and run queries against the 
channel data. 

In the previous experiment `org3` had no write access to the channel after joining. Now this
issue is resolved and `org3` can write and read channel data. Issue looks like some 
misconfiguration in the previous experiment.

## Chaincode upgrade

`file: org3_chaincode.sh`

Verify that while upgrading chaincode data is preserved. This scenario uses
modified chaincode example with added `migration` method.

## Granting admin priviledges

`file: org3_admin.sh`

The idea is to apply same steps from the first scenario to the system channel.
This channel grants rights for MSPs to create new channels. It is called
`testchannelid` by default and is not shown in `peer channel list` output.

Ordered org admin can add members to the system channel.

After running this scenario `org3` has the same rights as `org1` and `org2` -
for example, it can create new channels, instatiate chaincodes and run
transactions inside these channels.


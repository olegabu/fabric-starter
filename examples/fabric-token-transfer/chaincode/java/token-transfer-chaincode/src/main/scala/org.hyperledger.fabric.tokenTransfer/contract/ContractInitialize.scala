package org.hyperledger.fabric.tokenTransfer.contract

import org.enterprisedlt.fabric.contract.ContractContext
import org.enterprisedlt.fabric.contract.annotation.ContractInit
import org.hyperledger.fabric.tokenTransfer.Main


/**
  * @author Maxim Fedin
  */
trait ContractInitialize {

    self: Main.type =>
    @ContractInit
    def init(context: ContractContext): Unit = {
        //        context.store.put(s"org1", Account("org1", 10000000))
        //        context.store.put(s"org2", Account("org2", 10000000))
        //        context.store.put(s"org3", Account("org3", 10000000))
        //        context.store.put(s"org4", Account("org4", 10000000))
        //        context.store.put(s"org5", Account("org5", 10000000))
    }

}

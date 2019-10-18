package org.hyperledger.fabric.tokenTransfer

import com.github.apolubelov.fabric.contract.ContractBase
import org.hyperledger.fabric.tokenTransfer.contract.{ContractInitialize, TransferOperations}
import org.slf4j.{Logger, LoggerFactory}


object Main extends ContractBase
  with App
  with ContractInitialize
  with TransferOperations {


    // start SHIM chain code
    start(args)

    // setup log levels
    LoggerFactory
      .getLogger(Logger.ROOT_LOGGER_NAME)
      .asInstanceOf[ch.qos.logback.classic.Logger]
      .setLevel(ch.qos.logback.classic.Level.INFO)
    LoggerFactory
      .getLogger(this.getClass.getPackage.getName)
      .asInstanceOf[ch.qos.logback.classic.Logger]
      .setLevel(ch.qos.logback.classic.Level.INFO)
    LoggerFactory
      .getLogger(classOf[ContractBase].getPackage.getName)
      .asInstanceOf[ch.qos.logback.classic.Logger]
      .setLevel(ch.qos.logback.classic.Level.INFO)


}

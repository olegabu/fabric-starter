package org.hyperledger.fabric.tokenTransfer

/**
  * @author Maxim Fedin
  */
case class OperationHistory(
    operationId: String,
    sender: String,
    receiver: String,
    amount: Int,
    timestamp: String
)

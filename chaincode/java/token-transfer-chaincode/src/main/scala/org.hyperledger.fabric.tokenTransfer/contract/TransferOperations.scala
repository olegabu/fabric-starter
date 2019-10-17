package org.hyperledger.fabric.tokenTransfer

import com.github.apolubelov.fabric.contract.annotation.ContractOperation
import com.github.apolubelov.fabric.contract.{ContractContext, ContractResponse, Success}
import org.hyperledger.fabric.tokenTransfer.Main
import org.hyperledger.fabric.tokenTransfer.assets.{Account, OperationHistory}


/**
  * @author Maxim Fedin
  */
trait TransferOperations {

    self: Main.type =>

    @ContractOperation
    def transfer(context: ContractContext, sender: String, receiver: String, amount: Int): ContractResponse = {
        for {
            senderAccount <- context.store.get[Account](sender).toRight("No such sender")
            _ <- if (senderAccount.owner == receiver) Left("Sender and receiver should be different") else Right(())
            _ <- if (amount < 0) Left("Amount should be positive") else Right(())
            _ <- if (senderAccount.amount < amount) Left("Not enough tokens") else Right(())
        } yield {
            val receiverAmount = context.store.get[Account](receiver) match {
                case Some(account) => account.amount + amount
                case None => amount
            }
            context.store.put[Account](receiver, Account(receiver, receiverAmount))
            context.store.put[Account](sender, Account(sender, senderAccount.amount - amount))
            context.store.put[OperationHistory](context.transaction.id, OperationHistory(
                operationId = context.transaction.id,
                sender = sender,
                receiver = receiver,
                amount = amount,
                timestamp = context.transaction.timestamp.toString
            ))
        }
        Success()
    }

    @ContractOperation
    def listAccounts(context: ContractContext): ContractResponse = {
        Success(context.store.list[Account].toArray)
    }

    @ContractOperation
    def listOrganizations(context: ContractContext): ContractResponse = {
        Success(context.store.list[Account].map(_.key).toArray)
    }

    @ContractOperation
    def getOrganizationAccount(context: ContractContext): ContractResponse = {
        val mspId = context.clientIdentity.mspId
        Success(context.store.get[Account](mspId))
    }

    @ContractOperation
    def listOperationsHistory(context: ContractContext): ContractResponse = {
        Success(
            context.store.list[OperationHistory].toArray
              .filter(x => x.value.sender == context.clientIdentity.mspId) ++
              context.store.list[OperationHistory].toArray
                .filter(x => x.value.receiver == context.clientIdentity.mspId)
        )
    }


    @ContractOperation
    def getTokens(context: ContractContext, amountToAdd: Int): ContractResponse = {
        context.store.put[OperationHistory](context.transaction.id, OperationHistory(
            operationId = context.transaction.id,
            sender = "faucet",
            receiver = context.clientIdentity.mspId,
            amount = amountToAdd,
            timestamp = context.transaction.timestamp.toString
        ))
        val amount = context.store.get[Account](context.clientIdentity.mspId) match {
            case Some(account) => account.amount + amountToAdd
            case None => amountToAdd
        }
        context.store.put[Account](context.clientIdentity.mspId, Account(context.clientIdentity.mspId, amount))
        Success()
    }
}

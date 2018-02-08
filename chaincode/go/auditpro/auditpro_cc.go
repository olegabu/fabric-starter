/*
Licensed to Collabatix Inc
*/

// ====CHAINCODE EXECUTION SAMPLES (CLI) ==================

// ==== Invoke ledgerdata chaincode ====
// peer chaincode invoke -C ledgerdatacc -n ledgerdata -c '{"Args":["createLedgerEntry","assetID","auditprojsonstr"]}'
// peer chaincode invoke -C ledgerdatacc -n ledgerdata -c '{"Args":["updateLedgerEntry","assetID","auditprojsonstr"]}'

// ==== Query ledgerdata chaincode ====
// peer chaincode query -C ledgerdatacc -n ledgerdata -c '{"Args":["getAllLedgerEntries"]}'
// peer chaincode query -C ledgerdatacc -n ledgerdata -c '{"Args":["getLedgerEntry","assetID"]}'
// peer chaincode query -C ledgerdatacc -n ledgerdata -c '{"Args":["getLedgerEntriesForCriteria","assetID","assetType","transactionId","transactionType"]}'
// peer chaincode query -C ledgerdatacc -n ledgerdata -c '{"Args":["getHistoryForLedgerEntry","assetID"]}'

// Rich Query (Only supported if CouchDB is used as state database):
//   peer chaincode query -C ledgerdatacc -n ledgerdata -c '{"Args":["getLedgerEntriesForQuery","{\"selector\":{\"assetID\":\"A01\"}}"]}'

package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"

	"io/ioutil"
	"net/http"
)

// AuditproChaincode : Ledger data management Chaincode implementation
type AuditproChaincode struct {
}

// Auditpro : Ledger data - Auditpro structure
type Auditpro struct {
	// audit pro Id
	AuditProID string `json:"auditProId,omitempty"`

	// asset Id
	AssetID string `json:"assetId,omitempty"`

	// asset type
	AssetType string `json:"assetType,omitempty"`

	// transaction Id
	// Required: true
	TransactionID string `json:"transactionId"`

	// transaction type
	// Required: true
	TransactionType string `json:"transactionType"`

	// Originating txn id
	// Required: true
	OriginatingTxnID string `json:"originatingTxnId"`

	// ledger entry type
	// Required: true
	LedgerEntryType string `json:"ledgerEntryType"`

	// event Id
	// Required: true
	EventID string `json:"eventId"`

	// sub event Id
	// Required: false
	SubEventID string `json:"subEventId"`

	// crud log
	CrudLog CrudLog `json:"crudLog,omitempty"`

	// ledger
	// Required: true
	Ledger Ledger `json:"ledger"`

	// ledger chain
	LedgerChain LedgerChain `json:"ledgerChain,omitempty"`

	// owner
	Owner Owner `json:"owner,omitempty"`

	// process log
	ProcessLog ProcessLog `json:"processLog,omitempty"`

	// value
	Value Value `json:"value,omitempty"`
}

// CrudLog : Ledger data - Auditpro - CrudLog structure
type CrudLog struct {
	// created by org
	CreatedByOrg string `json:"createdByOrg,omitempty"`

	// created by user
	CreatedByUser string `json:"createdByUser,omitempty"`

	// created time stamp
	CreatedTimeStamp string `json:"createdTimeStamp,omitempty"`

	// updated by org
	UpdatedByOrg string `json:"updatedByOrg,omitempty"`

	// updated by user
	UpdatedByUser string `json:"updatedByUser,omitempty"`

	// updated time stamp
	UpdatedTimeStamp string `json:"updatedTimeStamp,omitempty"`
}

// Ledger : Ledger data - Auditpro - Ledger structure
type Ledger struct {
	// data
	Data string `json:"data,omitempty"`

	// data hash algo
	// Required: true
	DataHashAlgo string `json:"dataHashAlgo"`

	// data hash signature
	// Required: true
	DataHashSignature string `json:"dataHashSignature"`

	// reference
	// Required: true
	Reference string `json:"reference"`
}

// LedgerChain : Ledger data - Auditpro - LedgerChain structure
type LedgerChain struct {
	// orginating node Id
	OrginatingNodeID string `json:"orginatingNodeId,omitempty"`

	// orginating node type
	OrginatingNodeType string `json:"orginatingNodeType,omitempty"`

	// relations
	Relations []Relations `json:"relations"`
}

// Relations : Ledger data - Auditpro - Relations structure
type Relations struct {
	// rel Id
	RelID string `json:"relId,omitempty"`

	// rel type
	RelType string `json:"relType,omitempty"`
}

// Owner : Ledger data - Auditpro - Owner structure
type Owner struct {
	// owner Id
	OwnerID string `json:"ownerId,omitempty"`

	// owner type
	OwnerType string `json:"ownerType,omitempty"`

	// custody
	Custody string `json:"custody,omitempty"`
}

// ProcessLog : Ledger data - Auditpro - ProcessLog structure
type ProcessLog struct {
	// business process Id
	BusinessProcessID string `json:"businessProcessId,omitempty"`

	// data center Id
	DataCenterID string `json:"dataCenterId,omitempty"`

	// originating geo
	OriginatingGeo []string `json:"originatingGeo"`

	// server process Id
	ServerProcessID string `json:"serverProcessId,omitempty"`

	// target geo
	TargetGeo []string `json:"targetGeo"`
}

// Value : Ledger data - Auditpro - Value structure
type Value struct {
	// amount
	Amount float64 `json:"amount,omitempty"`

	// ccy
	Ccy string `json:"ccy,omitempty"`
}

// ===================================================================================
// Main
// ===================================================================================
func main() {
	err := shim.Start(new(AuditproChaincode))
	if err != nil {
		fmt.Printf("Error starting Ledger Data chaincode: %s", err)
	}
}

// Init initializes chaincode
// ===========================
func (t *AuditproChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

// Invoke - Our entry point for Invocations
// ========================================
func (t *AuditproChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	fmt.Println("invoke is running " + function)

	// Handle different functions
	if function == "createLedgerEntry" { //create a new Ledger Entry
		return t.createLedgerEntry(stub, args)
	} else if function == "updateLedgerEntry" { //update Ledger Entry
		return t.updateLedgerEntry(stub, args)
	} else if function == "getLedgerEntry" { //get Ledger Entry details
		return t.getLedgerEntry(stub, args)
	} else if function == "getAllLedgerEntries" { //get all Ledger Entries
		return t.getAllLedgerEntries(stub)
	} else if function == "getLedgerEntriesForQuery" { //get all Ledger Entries for query
		return t.getLedgerEntriesForQuery(stub, args)
	} else if function == "getHistoryForLedgerEntry" { //get history for Ledger Entry
		return t.getHistoryForLedgerEntry(stub, args)
	} else if function == "getLedgerEntriesForCriteria" { //get Ledger Entries for criteria
		return t.getLedgerEntriesForCriteria(stub, args)
	}

	fmt.Println("invoke did not find func: " + function) //error

	return shim.Error("Received unknown function invocation")
}

// ============================================================
// createLedgerEntry - create a new ledger entry, store into chaincode state
// ============================================================
func (t *AuditproChaincode) createLedgerEntry(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	fmt.Println("- start createLedgerEntry")

	//   0       			1
	// "LedgerID", "auditprojsonstr"
	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	// ==== Input sanitation ====
	if len(args[0]) <= 0 {
		return shim.Error("Ledger Id must be non-empty")
	}
	if len(args[1]) <= 0 {
		return shim.Error("Peer must be non-empty")
	}
	if len(args[2]) <= 0 {
		return shim.Error("Ledger data must be non-empty")
	}

	ledgerID := args[0]
	peerName := args[1]
	auditprojsonstr := args[2]

	//fmt.Println("- auditprojsonstr" + auditprojsonstr)

	/*
		// ==== Check if ledger entry already exists ====
		ledgerEntryAsBytes, err := stub.GetState(assetID)
		if err != nil {
			return shim.Error("Failed to get ledger entry: " + err.Error())
		} else if ledgerEntryAsBytes != nil {
			errmsg := "This ledger entry already exists: " + assetID
			fmt.Println(errmsg)
			return shim.Error(errmsg)
		}
	*/

	// ==== Create Ledger Entry object and marshal to JSON ====
	var auditpro Auditpro

	err = json.Unmarshal([]byte(auditprojsonstr), &auditpro) //unmarshal it aka JSON.parse()
	if err != nil {
		return shim.Error(err.Error())
	}

	ledgerEntryJSONasBytes, err := json.Marshal(auditpro)
	if err != nil {
		return shim.Error(err.Error())
	}

	// === Save ledger entry to state ===
	err = stub.PutState(ledgerID, ledgerEntryJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	//  ==== Index the ledger entry to enable criteria(assetID-assetType-transactionId-transactionType) based range queries, e.g. return all assetType=Company ====
	//  An 'index' is a normal key/value entry in state.
	//  The key is a composite key, with the elements that you want to range query on listed first.
	//  In our case, the composite key is based on assetID~assetType~transactionId~transactionType.
	//  This will enable very efficient state range queries based on composite keys matching auditprocriteria~*
	/*
		indexName := "auditprocriteria"
		auditprocriteriaIndexKey, err := stub.CreateCompositeKey(indexName, []string{ledgerID, auditpro.AssetType, auditpro.TransactionID, auditpro.TransactionType})
		if err != nil {
			return shim.Error(err.Error())
		}
		//  Save index entry to state. Only the key name is needed, no need to store a duplicate copy of the ledger entry.
		//  Note - passing a 'nil' value will effectively delete the key from state, therefore we pass null character as value
		value := []byte{0x00}
		stub.PutState(auditprocriteriaIndexKey, value)
	*/
	// ==== Ledger Entry saved and indexed. Return success ====

	//	Create log
	invokeTimeStr := time.Now().Format("2006-01-02T15:04:05.999999-07:00")

	/*
		hostname, hosterr := os.Hostname()
		if hosterr != nil {
			hostname = "Unknown"
		}
	*/

	dataSizeStr := strconv.Itoa((len(ledgerEntryJSONasBytes)))

	auditpro.Ledger.Data = ""

	ledgerEntryJSONasBytesNoLedgerData, err := json.Marshal(auditpro)
	if err != nil {
		return shim.Error(err.Error())
	}

	logdatajsonstr := map[string]string{"message": "Ledger Entry Created", "org": peerName, "correlationId": ledgerID, "invokeTime": invokeTimeStr, "size": dataSizeStr, "logDetails": string(ledgerEntryJSONasBytesNoLedgerData)}
	jsonValueLogdata, _ := json.Marshal(logdatajsonstr)

	logmessagejsonstr := map[string]string{"source": "LedgerSvc", "category": "info", "data": string(jsonValueLogdata)}

	//fmt.Println("logmessagejsonstr : ", logmessagejsonstr)

	jsonValue, _ := json.Marshal(logmessagejsonstr)
	host := "http://18.219.2.144:8222/logservice/"
	response, err := http.Post(host, "application/json", bytes.NewBuffer(jsonValue))
	if err != nil {
		fmt.Printf("The HTTP request failed with error %s\n", err)
	} else {
		data, _ := ioutil.ReadAll(response.Body)
		fmt.Println("Log Service Response : " + string(data))
	}

	fmt.Println("- end createLedgerEntry")
	return shim.Success(nil)
}

// ===========================================================
// update a Ledger Entry
// ===========================================================
func (t *AuditproChaincode) updateLedgerEntry(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	fmt.Println("- start updateLedgerEntry")

	// "assetID", "auditprojsonstr"
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	// ==== Input sanitation ====
	if len(args[0]) <= 0 {
		return shim.Error("Ledger Id must be non-empty")
	}
	if len(args[1]) <= 0 {
		return shim.Error("Ledger data must be non-empty")
	}

	assetID := args[0]
	auditprojsonstr := args[1]

	// ==== Check if ledger entry already exists ====
	ledgerEntryAsBytes, err := stub.GetState(assetID)
	if err != nil {
		return shim.Error("Failed to get ledger entry :" + err.Error())
	} else if ledgerEntryAsBytes == nil {
		return shim.Error("Ledger Entry does not exist" + assetID)
	}

	var auditproNew Auditpro

	err = json.Unmarshal([]byte(auditprojsonstr), &auditproNew) //unmarshal it aka JSON.parse()
	if err != nil {
		return shim.Error(err.Error())
	}

	var auditproToUpdate Auditpro

	err = json.Unmarshal(ledgerEntryAsBytes, &auditproToUpdate) //unmarshal it aka JSON.parse()
	if err != nil {
		return shim.Error(err.Error())
	}

	//update except for - assetID,assetType, - these should not change
	auditproToUpdate.AuditProID = auditproNew.AuditProID
	auditproToUpdate.CrudLog = auditproNew.CrudLog
	auditproToUpdate.Ledger = auditproNew.Ledger
	auditproToUpdate.LedgerChain = auditproNew.LedgerChain
	auditproToUpdate.Owner = auditproNew.Owner
	auditproToUpdate.ProcessLog = auditproNew.ProcessLog
	auditproToUpdate.Value = auditproNew.Value
	auditproToUpdate.TransactionID = auditproNew.TransactionID
	auditproToUpdate.TransactionType = auditproNew.TransactionType

	ledgerEntryJSONasBytes, _ := json.Marshal(auditproToUpdate)
	err = stub.PutState(assetID, ledgerEntryJSONasBytes) //rewrite the Ledger Entry
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("- end updateLedgerEntry")
	return shim.Success(nil)
}

// ===============================================
// getLedgerEntry - read a Ledger Entry from chaincode state
// ===============================================
func (t *AuditproChaincode) getLedgerEntry(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var assetID, jsonResp string
	var err error

	//   0
	// "assetID"
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting assetID of the Ledger Entry to query")
	}

	fmt.Println("- start getLedgerEntry")

	// ==== Input sanitation ====
	if len(args[0]) <= 0 {
		return shim.Error("Asset id must be non-empty")
	}

	assetID = args[0]
	valAsbytes, err := stub.GetState(assetID) //get the Ledger Entry from chaincode state
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get state for " + assetID + "\"}"
		return shim.Error(jsonResp)
	} else if valAsbytes == nil {
		jsonResp = "{\"Error\":\"Ledger Entry does not exist: " + assetID + "\"}"
		return shim.Error(jsonResp)
	}

	fmt.Println("- end getLedgerEntry")

	return shim.Success(valAsbytes)
}

// ===============================================
// getAllLedgerEntries - read all Ledger Entries from chaincode state
// ===============================================
func (t *AuditproChaincode) getAllLedgerEntries(stub shim.ChaincodeStubInterface) pb.Response {
	var startKey, endKey, jsonResp string
	var err error

	startKey = ""
	endKey = ""

	fmt.Println("- start getAllLedgerEntries")

	resultsIterator, err := stub.GetStateByRange(startKey, endKey)

	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get ledger entries : " + err.Error() + "\"}"
		return shim.Error(jsonResp)
	}

	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Println("- end getAllLedgerEntries")

	return shim.Success(buffer.Bytes())
}

// ===============================================
// getLedgerEntriesForCriteria - read all Ledger Entries from chaincode state for criteria
// ===============================================
func (t *AuditproChaincode) getLedgerEntriesForCriteria(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var compositeKeyName, jsonResp string
	var err error

	compositeKeyName = "auditprocriteria"

	fmt.Println("- start getLedgerEntriesForCriteria")

	//   0			1				2				3
	// "assetID", "assetType", "transactionId", "transactionType"
	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting at leaset one criteria to query")
	}

	assetID := args[0]
	assetType := args[1]
	transactionID := args[2]
	transactionType := args[3]

	resultsIterator, err := stub.GetStateByPartialCompositeKey(compositeKeyName, []string{assetID, assetType, transactionID, transactionType})

	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get ledger entries : " + err.Error() + "\"}"
		return shim.Error(jsonResp)
	}

	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		responseRange, err := resultsIterator.Next()
		if err != nil {
			jsonResp = "{\"Error\":\"Failed to get ledger entries : " + err.Error() + "\"}"
			return shim.Error(jsonResp)
		}

		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}

		// get the ledgerdataid from composite key dataobjecttype~ledgerdataid
		objectType, compositeKeyParts, err := stub.SplitCompositeKey(responseRange.Key)
		if err != nil {
			jsonResp = "{\"Error\":\"Failed to get ledger entries : " + err.Error() + "\"}"
			return shim.Error(jsonResp)
		}

		fmt.Println("SplitCompositeKey objectType : " + objectType)

		assetID := compositeKeyParts[0]

		// Call the getLedgerEntry for the key
		queryResponse := t.getLedgerEntry(stub, []string{assetID})
		if queryResponse.Status != shim.OK {
			jsonResp = "{\"Error\":\"Failed to get ledger entry for : " + assetID + " - Error : " + queryResponse.Message + "\"}"
			return shim.Error(jsonResp)
		}

		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Payload))
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Println("- end getLedgerEntriesForCriteria")

	return shim.Success(buffer.Bytes())
}

// ===============================================
// getLedgerEntriesForQuery - read all Ledger Entries from chaincode state for query
// Query string matching state database syntax is passed in and executed as is.
// Supports ad hoc queries that can be defined at runtime by the client.
// Only available on state databases that support rich query (e.g. CouchDB)
// ===============================================
func (t *AuditproChaincode) getLedgerEntriesForQuery(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	//   0
	// "queryString"
	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	queryString := args[0]

	queryResults, err := getQueryResultForQueryString(stub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}

// =========================================================================================
// getQueryResultForQueryString executes the passed in query string.
// Result set is built and returned as a byte array containing the JSON results.
// =========================================================================================
func getQueryResultForQueryString(stub shim.ChaincodeStubInterface, queryString string) ([]byte, error) {

	fmt.Printf("- getQueryResultForQueryString queryString:\n%s\n", queryString)

	resultsIterator, err := stub.GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryRecords
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is

		// ==== Remove Data from AuditPro ====
		auditprojson := queryResponse.Value
		var auditpro Auditpro

		err = json.Unmarshal([]byte(auditprojson), &auditpro) //unmarshal it aka JSON.parse()
		if err != nil {
			return nil, err
		}

		//clear data
		auditpro.Ledger.Data = ""

		ledgerEntryJSONasBytes, err := json.Marshal(auditpro)
		if err != nil {
			return nil, err
		}

		buffer.WriteString(string(ledgerEntryJSONasBytes))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	//fmt.Printf("- getQueryResultForQueryString queryResult:\n%s\n", buffer.String())
	fmt.Println("- end getQueryResultForQueryString")

	return buffer.Bytes(), nil
}

// =========================================================================================
// getHistoryForLedgerEntry returns the Transaction history
// for the ledger entry identified by the key.
// =========================================================================================
func (t *AuditproChaincode) getHistoryForLedgerEntry(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	assetID := args[0]

	fmt.Printf("- start getHistoryForLedgerEntry: %s\n", assetID)

	resultsIterator, err := stub.GetHistoryForKey(assetID)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the auditpro
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON Object)
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")
		/*
			buffer.WriteString(", \"IsDelete\":")
			buffer.WriteString("\"")
			buffer.WriteString(strconv.FormatBool(response.IsDelete))
			buffer.WriteString("\"")
		*/

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	//fmt.Printf("- getHistoryForLedgerEntry returning:\n%s\n", buffer.String())
	fmt.Println("- end getHistoryForLedgerEntry")

	return shim.Success(buffer.Bytes())
}

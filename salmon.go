package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
)

// Define the Smart Contract structure
type SmartContract struct {
}

type salmon struct {
	ObjectType string `json:"docType"`
	ID         string `json:"id"`
	Vessel     string `json:"vessel"`
	Datetime   string `json:"datetime"`
	Location   string `json:"localtion"`
	Holer      string `json:"holder"`
}

type deal struct {
	ObjectType string `json:"docType"`
	Buyer      string `json:"buyer"`
	Seller     string `json:"seller"`
	Price      int32  `json:"price"`
}

/*
 * The Init method is called when the Smart Contract "fabcar" is instantiated by the blockchain network
 * Best practice is to have any Ledger initialization in separate function -- see initLedger()
 */
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the Smart Contract "fabcar"
 * The calling application program has also specified the particular smart contract function to be called, with arguments
 */
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()

	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "recordSalmon" {
		return s.recordSalmon(APIstub, args)
	}

	if function == "changeSalmonHolder" {
		return s.changeSalmonHolder(APIstub, args)
	}

	if function == "querySalmon" {
		return s.querySalmon(APIstub, args)
	}

	if function == "queryAllSalmon" {
		return s.queryAllSalmon(APIstub)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	salmons := []salmon{
		salmon{
			ID:       "1",
			Vessel:   "vessel no1",
			Datetime: time.Now().Format(time.UnixDate),
			Location: "somewhere",
			Holer:    "someone",
		},
	}

	i := 0
	for i < len(salmons) {
		salmonAsBytes, _ := json.Marshal(salmons[i])
		APIstub.PutState("SALMON"+strconv.Itoa(i), salmonAsBytes)
		fmt.Println("Added", salmons[i])
		i = i + 1
	}

	return shim.Success(nil)
}

func (s *SmartContract) recordSalmon(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments. Expecting 5")
	}

	var salmon = salmon{
		Vessel:   args[1],
		Datetime: args[2],
		Location: args[3],
		Holer:    args[4],
	}

	salmonAsBytes, _ := json.Marshal(salmon)
	APIstub.PutState(args[0], salmonAsBytes)

	return shim.Success(nil)
}

func (s *SmartContract) queryAllCars(APIstub shim.ChaincodeStubInterface) sc.Response {

	startKey := "CAR0"
	endKey := "CAR999"

	resultsIterator, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
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
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- queryAllCars:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

func (s *SmartContract) changeCarOwner(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	carAsBytes, _ := APIstub.GetState(args[0])
	car := Car{}

	json.Unmarshal(carAsBytes, &car)
	car.Owner = args[1]

	carAsBytes, _ = json.Marshal(car)
	APIstub.PutState(args[0], carAsBytes)

	return shim.Success(nil)
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}

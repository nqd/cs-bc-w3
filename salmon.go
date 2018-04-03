package main

import (
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
	Holder     string `json:"holder"`
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
			Vessel:   "vessel no1",
			Datetime: time.Now().Format(time.UnixDate),
			Location: "somewhere",
			Holder:   "someone",
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
		Holder:   args[4],
	}

	salmonAsBytes, _ := json.Marshal(salmon)
	APIstub.PutState(args[0], salmonAsBytes)

	return shim.Success(nil)
}

func (s *SmartContract) changeSalmonHolder(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	// 0      1
	// id     owner

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	id := args[0]
	newHolder := args[1]

	salmonAsBytes, err := APIstub.GetState(id)
	if err != nil {
		return shim.Error("Failed to get salmon:" + err.Error())
	}
	if salmonAsBytes == nil {
		return shim.Error("Salmon does not exist")
	}
	salmonToTransfer := salmon{}
	err = json.Unmarshal(salmonAsBytes, &salmonToTransfer) // unmarshal it aka JSON.parse()
	if err != nil {
		return shim.Error(err.Error())
	}
	salmonToTransfer.Holder = newHolder //change the owner

	newSalmonAsByte, _ := json.Marshal(salmonToTransfer)
	err = stub.PutState(id, newSalmonAsByte) //rewrite the marble
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (s *SmartContract) querySalmon(APIstub shim.ChaincodeStubInterface) sc.Response {
	// 0
	// id

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	id := args[0]

	salmonAsBytes, err := APIstub.GetState(id)
	if err != nil {
		return shim.Error("Failed to get salmon:" + err.Error())
	}
	if salmonAsBytes == nil {
		return shim.Error("Salmon does not exist")
	}
	return shim.Success(salmonAsBytes)
}

// queryAllSalmon -- used by regulator to check sustainability of supply chain
// todo

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}

package w3

import (
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

type Salmon struct {
	ObjectType string `json:"docType"`
	ID         string `json:"id"`
	Vessel     string `json:"vessel"`
	Datetime   string `json:"datetime"`
	Holer      string `json:"holder"`
}

type Deal struct {
	ObjectType string `json:"docType"`
	Buyer      string `json:"buyer"`
	Seller     string `json:"seller"`
	Price      int32  `json:"price"`
}

// Init is called during chaincode instantiation to initialize any data.
func (t *Salmon) Init(stub shim.ChaincodeStubInterface) peer.Response {
	// Get the args from the transaction proposal
	args := stub.GetStringArgs()
	if len(args) != 2 {
		return shim.Error("Incorrect arguments. Expecting a key and a value")
	}
}

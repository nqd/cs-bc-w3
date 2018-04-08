#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

./jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

CC_SRC_PATH="github.com/salmon/go"
# CC_SRC_PATH="$PWD/artifacts/src/github.com/salmon/node"

echo "POST request Enroll on Alice  ..."
echo
ALICE_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=aliceuser&orgName=alice')
echo $ALICE_TOKEN
ALICE_TOKEN=$(echo $ALICE_TOKEN | ./jq ".token" | sed "s/\"//g")
echo
echo "ALICE token is $ALICE_TOKEN"
echo

echo "POST request Enroll on Bob ..."
echo
BOB_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=bobuser&orgName=bob')
echo $BOB_TOKEN
BOB_TOKEN=$(echo $BOB_TOKEN | ./jq ".token" | sed "s/\"//g")
echo
echo "BOB token is $BOB_TOKEN"
echo

echo "POST request Enroll on Fredrick ..."
echo
FREDRICK_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=fredrickuser&orgName=fredrick')
echo $FREDRICK_TOKEN
FREDRICK_TOKEN=$(echo $FREDRICK_TOKEN | ./jq ".token" | sed "s/\"//g")
echo
echo "FREDRICK token is $FREDRICK_TOKEN"
echo

echo
echo "POST request Create channel  ..."
echo
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"fredrick-alice",
	"channelConfigPath":"../artifacts/channel/fredrick-alice.tx"
}'
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"fredrick-bob",
	"channelConfigPath":"../artifacts/channel/fredrick-bob.tx"
}'
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"transfer",
	"channelConfigPath":"../artifacts/channel/transfer.tx"
}'
echo
echo

exit
sleep 5
echo "POST request Join channel on Fredrick-Alice"
echo
curl -s -X POST \
  http://localhost:4000/channels/fredrick-alice/peers \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.alice.example.com","peer0.fredrick.example.com"]
}'
echo
echo

echo "POST request Join channel on Fredrick-Bob"
echo
curl -s -X POST \
  http://localhost:4000/channels/fredrick-/peers \
  -H "authorization: Bearer $BOB_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org2.example.com","peer1.org2.example.com"]
}'
echo
echo

echo "POST Install chaincode on Alice"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org1.example.com\",\"peer1.org1.example.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Bob"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $BOB_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org2.example.com\",\"peer1.org2.example.com\"],
	\"chaincodeName\":\"mycc\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST instantiate chaincode on peer1 of Alice"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"mycc\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"args\":[\"a\",\"100\",\"b\",\"200\"]
}"
echo
echo

echo "POST invoke chaincode on peers of Alice"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"move",
	"args":["a","b","10"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "GET query chaincode on peer1 of Alice"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22a%22%5D" \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Block by blockNumber"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/blocks/1?peer=peer0.org1.example.com" \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Transaction by TransactionID"
echo
curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID?peer=peer0.org1.example.com \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json"
echo
echo

############################################################################
### TODO: What to pass to fetch the Block information
############################################################################
#echo "GET query Block by Hash"
#echo
#hash=????
#curl -s -X GET \
#  "http://localhost:4000/channels/mychannel/blocks?hash=$hash&peer=peer1" \
#  -H "authorization: Bearer $ALICE_TOKEN" \
#  -H "cache-control: no-cache" \
#  -H "content-type: application/json" \
#  -H "x-access-token: $ALICE_TOKEN"
#echo
#echo

echo "GET query ChainInfo"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel?peer=peer0.org1.example.com" \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Installed chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/chaincodes?peer=peer0.org1.example.com" \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Instantiated chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes?peer=peer0.org1.example.com" \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Channels"
echo
curl -s -X GET \
  "http://localhost:4000/channels?peer=peer0.org1.example.com" \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json"
echo
echo


echo "Total execution time : $(($(date +%s)-starttime)) secs ..."

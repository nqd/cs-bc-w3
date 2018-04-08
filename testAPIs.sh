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

CC_SRC_PATH="github.com/nqd/salmon_transfer"
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
	"channelName":"transfers",
	"channelConfigPath":"../artifacts/channel/transfers.tx"
}'
echo
echo

sleep 5
echo "POST request Join channel on Fredrick-Alice"
echo
curl -s -X POST \
  http://localhost:4000/channels/fredrick-alice/peers \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.alice.coderschool.vn"]
}'
echo
echo

echo "POST request Join channel on Fredrick-Alice"
echo
curl -s -X POST \
  http://localhost:4000/channels/fredrick-alice/peers \
  -H "authorization: Bearer $FREDRICK_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.fredrick.coderschool.vn"]
}'
echo
echo
# ---------
echo "POST request Join channel on Fredrick-Bob"
echo
curl -s -X POST \
  http://localhost:4000/channels/fredrick-bob/peers \
  -H "authorization: Bearer $FREDRICK_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.fredrick.coderschool.vn"]
}'
echo
echo
echo "POST request Join channel on Fredrick-Bob"
echo
curl -s -X POST \
  http://localhost:4000/channels/fredrick-bob/peers \
  -H "authorization: Bearer $BOB_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.bob.coderschool.vn"]
}'
echo
echo

# ---------
# todo: all join transfers
echo "POST request Join channel on Transfers"
echo
curl -s -X POST \
  http://localhost:4000/channels/transfers/peers \
  -H "authorization: Bearer $FREDRICK_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.fredrick.coderschool.vn"]
}'
echo
echo
echo "POST request Join channel on Transfer"
echo
curl -s -X POST \
  http://localhost:4000/channels/transfers/peers \
  -H "authorization: Bearer $BOB_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.bob.coderschool.vn"]
}'
echo
echo
echo "POST request Join channel on Transfer"
echo
curl -s -X POST \
  http://localhost:4000/channels/transfers/peers \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.alice.coderschool.vn"]
}'
echo
echo

# -------------------------------
echo "POST Install chaincode on Alice"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.alice.coderschool.vn\"],
	\"chaincodeName\":\"salmon_price_cc\",
	\"chaincodePath\":\"github.com/nqd/salmon_price\",
	\"chaincodeType\": \"go\",
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
	\"peers\": [\"peer0.bob.coderschool.vn\"],
	\"chaincodeName\":\"salmon_price_cc\",
	\"chaincodePath\":\"github.com/nqd/salmon_price\",
	\"chaincodeType\": \"go\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo
echo "POST Install chaincode on Fredrick"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $FREDRICK_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.fredrick.coderschool.vn\"],
	\"chaincodeName\":\"salmon_price_cc\",
	\"chaincodePath\":\"github.com/nqd/salmon_price\",
	\"chaincodeType\": \"go\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST instantiate chaincode on fredrick-alice"
echo
curl -s -X POST \
  http://localhost:4000/channels/fredrick-alice/chaincodes \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"salmon_price_cc\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"go\",
	\"args\":[]
}"
echo
echo
echo "POST instantiate chaincode on fredrick-bob"
echo
curl -s -X POST \
  http://localhost:4000/channels/fredrick-bob/chaincodes \
  -H "authorization: Bearer $BOB_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"salmon_price_cc\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"go\",
	\"args\":[]
}"
echo
echo

# -------------------------------
echo "POST Install salmon_transfer chaincode on Alice"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.alice.coderschool.vn\"],
	\"chaincodeName\":\"salmon_transfer_cc\",
	\"chaincodePath\":\"github.com/nqd/salmon_transfer\",
	\"chaincodeType\": \"go\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo
echo "POST Install salmon_transfer chaincode on Bob"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $BOB_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.bob.coderschool.vn\"],
	\"chaincodeName\":\"salmon_transfer_cc\",
	\"chaincodePath\":\"github.com/nqd/salmon_transfer\",
	\"chaincodeType\": \"go\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo
echo "POST Install salmon_transfer chaincode on Bob"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $FREDRICK_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.fredrick.coderschool.vn\"],
	\"chaincodeName\":\"salmon_transfer_cc\",
	\"chaincodePath\":\"github.com/nqd/salmon_transfer\",
	\"chaincodeType\": \"go\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo
echo "POST instantiate salmon_transfer chaincode"
echo
curl -s -X POST \
  http://localhost:4000/channels/transfers/chaincodes \
  -H "authorization: Bearer $ALICE_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"salmon_transfer_cc\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"go\",
	\"args\":[]
}"
echo
echo

# ----------------------------------
echo "POST invoke chaincode on peers of Alice"
echo
curl -s -X POST \
  http://localhost:4000/channels/transfers/chaincodes/salmon_transfer_cc \
  -H "authorization: Bearer $BOB_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.bob.coderschool.vn\"],
	\"fcn\":\"querySalmon\",
	\"args\":[\"SALMON0\"]
}"
echo
echo

curl -s -X POST \
  http://localhost:4000/channels/transfers/chaincodes/salmon_transfer_cc \
  -H "authorization: Bearer $BOB_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.bob.coderschool.vn\"],
	\"fcn\":\"recordSalmon\",
	\"args\":[\"1\",\"1\",\"1\",\"1\",\"1\"]
}"
curl -s -X GET http://localhost:4000/channels/transfers/transactions/751f0dc07c4229e5274f5279e2cd99ccb6cff37a1d7447dacaf2966b1cccb2af?peer=peer0.bob.coderschool.vn \
  -H "authorization: Bearer $BOB_TOKEN" \
  -H "content-type: application/json"

curl -s -X GET \
  "http://localhost:4000/channels/transfers/chaincodes/salmon_transfer_cc?peer=peer0.bob.coderschool.vn&fcn=querySalmon&args=%5B%221%22%5D" \
  -H "authorization: Bearer $BOB_TOKEN" \
  -H "content-type: application/json"
echo
# echo "GET query chaincode on peer1 of Alice"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.coderschool.vn&fcn=query&args=%5B%22a%22%5D" \
#   -H "authorization: Bearer $ALICE_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

# echo "GET query Block by blockNumber"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/blocks/1?peer=peer0.org1.coderschool.vn" \
#   -H "authorization: Bearer $ALICE_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

# echo "GET query Transaction by TransactionID"
# echo
# curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID?peer=peer0.org1.coderschool.vn \
#   -H "authorization: Bearer $ALICE_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

# ############################################################################
# ### TODO: What to pass to fetch the Block information
# ############################################################################
# #echo "GET query Block by Hash"
# #echo
# #hash=????
# #curl -s -X GET \
# #  "http://localhost:4000/channels/mychannel/blocks?hash=$hash&peer=peer1" \
# #  -H "authorization: Bearer $ALICE_TOKEN" \
# #  -H "cache-control: no-cache" \
# #  -H "content-type: application/json" \
# #  -H "x-access-token: $ALICE_TOKEN"
# #echo
# #echo

# echo "GET query ChainInfo"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel?peer=peer0.org1.coderschool.vn" \
#   -H "authorization: Bearer $ALICE_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

# echo "GET query Installed chaincodes"
# echo
# curl -s -X GET \
#   "http://localhost:4000/chaincodes?peer=peer0.org1.coderschool.vn" \
#   -H "authorization: Bearer $ALICE_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

# echo "GET query Instantiated chaincodes"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes?peer=peer0.org1.coderschool.vn" \
#   -H "authorization: Bearer $ALICE_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

# echo "GET query Channels"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels?peer=peer0.org1.coderschool.vn" \
#   -H "authorization: Bearer $ALICE_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo


echo "Total execution time : $(($(date +%s)-starttime)) secs ..."

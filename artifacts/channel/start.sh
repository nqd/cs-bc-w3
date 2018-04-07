cryptogen generate --config=./cryptogen.yaml

for file in $(find crypto-config -iname *_sk); do dir=$(dirname $file); mv ${dir}/*_sk ${dir}/key.pem; done

configtxgen -profile ThreeOrgsOrdererGenesis -outputBlock genesis.block

configtxgen -profile ThreeOrgsChannel -outputCreateChannelTx fredrick-alice.tx -channelID fredrick-alice

configtxgen -profile ThreeOrgsChannel -outputCreateChannelTx fredrick-bob.tx -channelID fredrick-bob

configtxgen -profile ThreeOrgsChannel -outputCreateChannelTx transfers.tx -channelID transfers

configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate AliceMSPanchors.tx -channelID transfers -asOrg AliceMSP

configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate BobMSPanchors.tx -channelID transfers -asOrg BobMSP

configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate FredrickMSPanchors.tx -channelID transfers -asOrg FredrickMSP
## Teleporter Starter Kit

# Set Up

```
avalanche subnet create mysubnet
```

```
avalanche subnet deploy mysubnet
```

```
avalanche subnet describe mysubnet
```

Make sure to add the RPC Url to the `foundry.toml` file if you have chosen a different name than `mysubnet`. If you've used `mysubnet` the rpc is already configured.

```
[rpc_endpoints]
local-c = "http://localhost:9650/ext/bc/C/rpc"
mysubnet = "http://localhost:9650/ext/bc/mysubnet/rpc"
anothersubnet = "http://localhost:9650/ext/bc/BASE58_BLOCKCHAIN_ID/rpc"
```


# Issuing Transactions with Foundry

## Local Network

For convenience the private key `56289e99c94b6912bfc12adc093c9b51124f0dc54ac7a766b2bc5ccf558d8027` of the default airdrop address is stored in the environment variable `$PK`. Furthermore, the RPC-url for the C-Chain of your local network is set in the `foundry.toml` file. 

### Setting the Blockchain ID in the Contracts

Make sure to replace the blockchainID in the sender contract `src/0-send-receive/senderOnCChain.sol` with the ID of your Subnet's blockchain. You can find the blockchainID of your Subnet with this command:

```
cast call --rpc-url mysubnet 0x0200000000000000000000000000000000000005 "getBlockchainID()(bytes32)" 
``` 

```
teleporterMessenger.sendCrossChainMessage(
    TeleporterMessageInput({
        // Replace with chain id of your Subnet (see instructions in Readme)
        destinationBlockchainID: 0x92756d698399805f0088fc07fc42af47c67e1d38c576667ac6c7031b8df05293,
        destinationAddress: destinationAddress,
        
        // ...
    })
);
```

### Deploying the Contracts

After adapting the contracts you can deploy them with `forge create`:

```
forge create --rpc-url local-c --private-key $PK src/0-send-receive/senderOnCChain.sol:SenderOnCChain

```

```
forge create --rpc-url mysubnet --private-key $PK src/0-send-receive/receiverOnSubnet.sol:ReceiverOnSubnet

```

### Sending a Message

You can find `<sender_contract_address>` in the output of the first and the `<receiver_contract_address>` of the second `forge create` command in the line saying `Deployed to:`.

```
cast send --rpc-url local-c --private-key $PK <sender_contract_address> "sendMessage(address,string)" <receiver_contract_address> "Hello"
```

### Verifying Message Receipt
```
cast call --rpc-url mysubnet <receiver_contract_address> "lastMessage()(string)"
```

## Fuji Testnet

### Creating a Wallet 

For deploying on testnet, we cannot use the airdrop wallet, since the private key is commonly known. To create a new wallet that is stored in a keystore, issue the following command. It will prompt you to secure the private key with a password.

```
cast wallet new .
```

You should now see a new Keystore in the root of your project looking something like this `c3832921-d2e6-4d9a-ba6f-017a37b12571`. Rename this file to `keystore`. For easier use of the keystore we already configured a envorinment variable called `KEYSTORE` pointing to the `keystore` file in the working directory.

You can use the wallet stored in the keystore by adding the `--keystore` flag instead of the `--private-key` flag.

```
cast wallet address --keystore $KEYSTORE
```

### Funding your Wallet with Fuji Tokens

Head to the [Avalanche Testnet Faucet](https://core.app/tools/testnet-faucet/?subnet=c&token=c) and fund your keystore address with Fuji AVAX and Dispatch tokens. Use the coupon code `avalanche-academy`.

### Setting the Blockchain ID in the Contracts

Make sure to adapt the destinationBlockchainID of your contracts to use the blockchain IDs of the Fuji network:

| Chain | Blockchain ID |
|-------|---------------|
| Fuji C-Chain | 0x7fc93d85c6d62c5b2ac0b519c87010ea5294012d1e407030d6acd0021cac10d5 |
| Dispatch | 0x9f3be606497285d0ffbb5ac9ba24aa60346a9b1812479ed66cb329f394a4b1c7 |

### Deploying the Contracts

After adapting the contracts you can deploy them using your keystore wallet:

```
forge create --rpc-url fuji-c --keystore $KEYSTORE src/0-send-receive/senderOnCChain.sol:SenderOnCChain
```

```
forge create --rpc-url dispatch --keystore $KEYSTORE src/0-send-receive/receiverOnSubnet.sol:ReceiverOnSubnet

```

### Sending a Message

```
cast send --rpc-url fuji-c --keystore $KEYSTORE <sender_contract_address> "sendMessage(address,string)" <receiver_contract_address> "Hello"
```

### Verifying Message Receipt
```
cast call --rpc-url dispatch <receiver_contract_address> "lastMessage()(string)"
```
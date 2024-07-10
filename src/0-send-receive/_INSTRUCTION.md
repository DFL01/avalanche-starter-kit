# Conditional Allowlist
In this example we launched a permissioned subnet with a transaction allowlist precompile to enhance the security and manageability of our Subnet. A smart contract deployed on the C-Chain is responsible for managing this allowlist.

Our system supports the following use cases for adding users to the allowlist:

A. Sender Contract Activation: Users can be added to the allowlist by calling a specific sender contract. This facilitates automatic enrollment based on predetermined criteria or actions within the network.

B. One-Time Fee Payment: Users gain access to the allowlist by paying a one-time fee. This straightforward method ensures immediate entry for users willing to contribute a specified amount.

C. (implemented but not fully functioning YET) Deposit and Withdrawal Mechanism: Users can be added to the allowlist by depositing a fee. This amount can be withdrawn later, which will result in their removal from the allowlist.


## What we have to do

1. Create a Subnet (with the Transaction Allowlist Precompile Enabled)
2. Deploy Subnet on Local Network
3. Deploy the Managing Receiver on the Subnet & the Sender Contract on the C-Chain
4. Add Managing Receiver Contract as Manager of the Transaction Allowlist
5. Send message from the Sender Contract to the Receiver Contract from C-Chain
6. Check if address was added to Allowlist

## Local Network Environment

For convenience the private key `56289e99c94b6912bfc12adc093c9b51124f0dc54ac7a766b2bc5ccf558d8027` of the default airdrop address is stored in the environment variable `$PK` in `.devcontainer/devcontainer.json`. Furthermore, the RPC url for the C-Chain `local-c` and Subnet created with the name `mysubnet` on the local network is set in the `foundry.toml` file.


## 1. Create a Subnet

To get started, create a Subnet configuration named "mysubnet":
    avalanche subnet create mysubnet

Configure the subnet to enable Teleporter, AWM Relayer and Transaction Allowlist:
```
✔ Use latest release version
✔ Yes
✔ Yes
Installing subnet-evm-v0.6.6...
subnet-evm-v0.6.6 installation successful
creating genesis for subnet mySubnet
Enter your subnet's ChainId. It can be any positive integer.
ChainId: 24
Select a symbol for your subnet's native token
Token symbol: ETHCC
✔ Low disk use    / Low Throughput    1.5 mil gas/s (C-Chain's setting)
✔ Airdrop 1 million tokens to the default ewoq address (do not use in production)
prefunding address 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC with balance 1000000000000000000000000

? Advanced: Would you like to add a custom precompile to modify the EVM?: 
    No
▸ Yes
    Go back to previous step

prefunding address 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC with balance 1000000000000000000000000
✔ Yes

? Choose precompile: 
    Native Minting
    Contract Deployment Allow List
▸ Transaction Allow List
    Adjust Fee Settings Post Deploy
    Customize Fees Distribution
    Cancel
✔ Transaction Allow List

? Configure the addresses that are allowed to issue transactions: 
▸ Add an address for a role to the allow list
    Preview Allow List
    Confirm Allow List
    Cancel
✔ Add an address for a role to the allow list

? What role should the address have?: 
▸ Admin
    Manager
    Enabled
    Explain the difference
    Cancel
✔ Admin

✔ Enter the address of the account (or multiple comma separated): 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC

? Configure the addresses that are allowed to issue transactions: 
    Add an address for a role to the allow list
    Remove address from the allow list
    Preview Allow List
▸ Confirm Allow List
    Cancel
✔ Confirm Allow List
+---------+--------------------------------------------+
| Admins  | 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC |
+---------+--------------------------------------------+
| Manager |                                            |
+---------+--------------------------------------------+
| Enabled |                                            |
+---------+--------------------------------------------+

? Confirm?: 
▸ Yes
    No, keep editing
✔ Yes

? Would you like to add additional precompiles?: 
▸ No
    Yes
    Go back to previous step
✓ Successfully created subnet configuration
```
## 2. Deploy Subnet on Local Network
    avalanche subnet deploy mysubnet

## 3. Deploy the Managing Reiceiver Contract on the Subnet & the Sender Contract on the C-Chain

### Deploy the Managing Receiver on the Subnet
Part A & B:
    forge create --rpc-url mysubnet --private-key $PK src/0-send-receive/receiverOnSubnet.sol:ReceiverOnSubnet

Part C: 
    forge create --rpc-url mysubnet --private-key $PK src/0-send-receive/receiverOnSubnetDeposit.sol:ReceiverOnSubnetDeposit
    
### Deploy the Sender Contract on the C-Chain

Part A:

    forge create --rpc-url local-c --private-key $PK src/0-send-receive/senderOnCChain.sol:SenderOnCChain

Part B:

    forge create --rpc-url local-c --private-key $PK src/0-send-receive/senderOnCChainFee.sol:SenderOnCChainFee

Part C:

    forge create --rpc-url local-c --private-key $PK src/0-send-receive/senderOnCChainDeposit.sol:SenderOnCChainDeposit

### Contract Addreses

    export RECEIVER_CONTRACT=0x52C84043CD9c865236f11d9Fc9F56aa003c1f922
    export SENDER_CONTRACT=0xA4cD3b0Eb6E5Ab5d8CE4065BcCD70040ADAB1F00

## 4. Give the Managing Reiceiver Contract the role of Manager of the Transaction Allowlist

Sets the Receiver Contract as the manager of the transaction allowlist
```
cast send --rpc-url mysubnet --private-key $PK 0x0200000000000000000000000000000000000002 "setManager(address)" 0x52C84043CD9c865236f11d9Fc9F56aa003c1f922
```

Check to see if the the Receiver Contract has been added to the allowlist
```
cast call --rpc-url mysubnet --private-key $PK 0x0200000000000000000000000000000000000002 "readAllowList(address)" 0x52C84043CD9c865236f11d9Fc9F56aa003c1f922
```

Should return:

```0x0000000000000000000000000000000000000000000000000000000000000003``` for admin  ```0x0000000000000000000000000000000000000000000000000000000000000002``` for manager
```0x0000000000000000000000000000000000000000000000000000000000000001``` for enabled

*Note: We first checked with the command "avalanche subnet describe mysubnet" and thought it didn't work. We then encountered that this was just a UX problem so we raised the following issue: https://github.com/ava-labs/avalanche-cli/issues/2022*


## 5. Send message from the Sender Contract to the Receiver Contract from C-Chain

### Create a new wallet
```cast wallet new```

```
Successfully created new keypair.
Address:     0xe22187fC2aFb7590cB1dd18877f7BEDFAE2A7675
Private key: 0x6f45447747cf70bd3b494f5cff8283997bd70b085aca8577bd716ef5bb600496
```


### Fund new wallet from eqoq address

```cast send --rpc-url local-c --private-key $PK 0xe22187fC2aFb7590cB1dd18877f7BEDFAE2A7675 --value 1ether```


### Part A: Send Message to Sender Contract
To simply send a message with no fee or conditional requirement to join the subnet then you can implement the following.

```cast send --rpc-url local-c --private-key <private key of new wallet> <address of sender contract> "sendMessage()"```


```cast send --rpc-url local-c --private-key 0x6f45447747cf70bd3b494f5cff8283997bd70b085aca8577bd716ef5bb600496 0xA4cD3b0Eb6E5Ab5d8CE4065BcCD70040ADAB1F00 "sendMessage()"```

### Part B: Send Message to Sender Contract with fee
If you implement use case 2 where the user has to pay a one-time fee, you should use the following command instead to add the fee to the command:
```
cast send --rpc-url local-c --private-key 0xd94ebed130ac357ace7d7201310d154a348185fb619be276bc09f01c4f91d98b 0xa4DfF80B4a1D748BF28BC4A271eD834689Ea3407 "sendMessage()" --value 0.03ether
```

### Part C: Send Message to Sender Contract with deposit
If you implement use case 3 where the user will send a deposit, you should use the following command:
```
cast send --rpc-url local-c --private-key 0xd94ebed130ac357ace7d7201310d154a348185fb619be276bc09f01c4f91d98b 0xa4DfF80B4a1D748BF28BC4A271eD834689Ea3407 "Deposit()" --value 0.02ether
```

You can also withdraw from the subnet and recover your initial deposit using the following command:
```
cast send --rpc-url local-c --private-key 0xd94ebed130ac357ace7d7201310d154a348185fb619be276bc09f01c4f91d98b 0xa4DfF80B4a1D748BF28BC4A271eD834689Ea3407 "Withdraw()" --value 0.02ether
```


## 6. Check if Adress was added to Allowlist
    cast call --rpc-url mysubnet --private-key $PK 0x0200000000000000000000000000000000000002 "readAllowList(address)" 0xe22187fC2aFb7590cB1dd18877f7BEDFAE2A7675


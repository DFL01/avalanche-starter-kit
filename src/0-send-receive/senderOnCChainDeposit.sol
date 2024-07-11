// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.18;

import "@teleporter/ITeleporterMessenger.sol";

contract SenderOnCChainDeposit {
    ITeleporterMessenger public immutable messenger = ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);
    address public owner;

    // Mapping to store user deposits
    mapping(address => uint256) private userDeposits;

    // Modifier to restrict functions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Modifier to restrict functions to the user who made the deposit
    modifier onlyUser() {
        require(userDeposits[msg.sender] > 0, "No deposit found for this user");
        _;
    }

    // Constructor to set the owner of the contract
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Sends a message to another chain.
     * JOIN (bool): True will join user to the subnet, False will withdraw user from subnet
     */
    function sendMessage(bool join) internal onlyUser {
        messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                destinationBlockchainID: 0x55e1fcfdde01f9f6d4c16fa2ed89ce65a8669120a86f321eef121891cab61241,
                destinationAddress: 0x52C84043CD9c865236f11d9Fc9F56aa003c1f922,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: 1000000,
                allowedRelayerAddresses: new address[](0),
                message: abi.encode(msg.sender, join)
            })
        );
    }

    // Function for users to make a deposit
    function deposit() external payable {
        require(msg.value > 0.02 ether, "Deposit amount must be greater than 0.02 Eth");
        userDeposits[msg.sender] += msg.value;
        sendMessage(true);
    }

    // Function for users to withdraw their deposit
    function withdraw() external onlyUser {
        uint256 amount = userDeposits[msg.sender];
        userDeposits[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        sendMessage(false);
    }
}

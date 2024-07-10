// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.18;

import "@teleporter/ITeleporterMessenger.sol";

contract SenderOnCChainFee {
    ITeleporterMessenger public immutable messenger = ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);
    uint256 public constant FEE_AMOUNT = 0.02 ether; // Define the fee amount
    address public owner; // Contract owner

    constructor() {
        owner = msg.sender; // Set the contract deployer as the owner
    }

    /**
     * @dev Sends a message to another chain.
     * Requires the caller to pay a one-time fee.
     */
    function sendMessage() external payable {
        require(msg.value >= FEE_AMOUNT, "Insufficient fee");

        // Forward the fee to the owner
        (bool sent,) = owner.call{value: msg.value}("");
        require(sent, "Failed to send Ether");

        messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                // Replace with blockchainID of your Subnet (see instructions in Readme)
                destinationBlockchainID: 0x216f92e177e22daa815811e6de0ce269e447dba4fcc3af60eb8a4c53caf121aa,
                destinationAddress: 0x52C84043CD9c865236f11d9Fc9F56aa003c1f922,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: 1000000,
                allowedRelayerAddresses: new address[](0),
                message: abi.encode(msg.sender)
            })
        );
    }

    /**
     * @dev Allows the owner to withdraw Ether from the contract.
     */
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        (bool sent,) = owner.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

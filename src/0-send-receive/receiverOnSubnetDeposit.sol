// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.18;

import "@teleporter/ITeleporterMessenger.sol";
import "@teleporter/ITeleporterReceiver.sol";
import "./txAllowList.sol";

contract ReceiverOnSubnetDeposit is ITeleporterReceiver {
    ITeleporterMessenger public immutable messenger = ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);

    IAllowList txAllowList = IAllowList(0x0200000000000000000000000000000000000002);

    string public lastMessage;

    function receiveTeleporterMessage(bytes32, address, bytes calldata message) external {
        // Only the Teleporter receiver can deliver a message.
        require(msg.sender == address(messenger), "ReceiverOnSubnet: unauthorized TeleporterMessenger");

        // Store the message.
        address newParticipant = abi.decode(message, (address));

        if (join) {
            txAllowList.setEnabled(newParticipant);
        } else {
            txAllowList.setNone(newParticipant);
        }
    }
}

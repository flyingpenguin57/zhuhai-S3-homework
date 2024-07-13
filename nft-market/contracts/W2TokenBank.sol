// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";

contract W2TokenBank is IERC1363Receiver {
    mapping(address => uint256) public bankBalance;

    bytes4 private selector = 0x88a7ca5c;

    function onTransferReceived(
        address operator,
        address from,
        uint256 amount,
        bytes memory data
    ) external returns (bytes4) {
        bankBalance[from] += amount;
        return selector;
    }
}

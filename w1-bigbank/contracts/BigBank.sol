// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./Bank.sol";
import "./Ownable.sol";

contract BigBank is Bank {

    uint256 MINIMUM_AMOUNT = 10 ** 15; //0.001eth

    modifier amountBiggerThan(uint amount) {
        require(msg.value >= amount, "deposit amount too small.");
        _;
    }

    //receive eth transfer from other address
    receive() external payable amountBiggerThan(MINIMUM_AMOUNT) {
        //update balance
        accountBalance[msg.sender] += msg.value;

        //sort
        sort();
    }
}

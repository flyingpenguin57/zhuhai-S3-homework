// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./Bank.sol";

contract BigBank is Bank {
    uint256 MINIMUM_AMOUNT = 10 ** 15; //0.001eth

    address admin;

    constructor(address admin_) {
        admin = admin_;
    }

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

    function withdraw(uint amount) public {
        require(msg.sender == admin, "no access");
        _withdraw(amount);
    }

    function setAdmin(address addr) public {
        require(msg.sender == admin, "no access");
        admin = addr;
    }
}

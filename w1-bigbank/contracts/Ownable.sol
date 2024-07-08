// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./BigBank.sol";

contract Ownable {
    BigBank bank;

    constructor(address payable addr) {
        bank = BigBank(addr);
    }

    function withdraw(uint amount) public {
        bank.withdraw(amount);
    }
}

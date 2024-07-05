// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Ownable {

    //owner
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "no access.");
        _;
    }

    //transfer ownerShip, only owner can do this
    function transferOwnership(address newOwner) public onlyOwner() {
        owner = newOwner;
    }
}
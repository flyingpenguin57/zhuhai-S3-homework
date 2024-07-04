// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Bank is Ownable {
    //构造函数 初始化owner
    constructor() Ownable(msg.sender) {}

    //admin
    mapping(address => bool) public admin;

    //account to balance
    mapping(address => uint) public accountBalance;

    //top3 deposit address
    address[3] public top3;

    //add admin, only owner can do this
    function addAdmin(address _newAdmin) public onlyOwner {
        admin[_newAdmin] = true;
    }

    //remove admin, only owner can do this
    function removeAdmin(address _admin) public onlyOwner {
        if (admin[_admin]) {
            admin[_admin] = false;
        }
    }

    //receive eth transfer from other address
    receive() external payable {
        //update balance
        accountBalance[msg.sender] += msg.value;

        //sort
        if (
            accountBalance[msg.sender] > accountBalance[top3[top3.length - 1]]
        ) {
            if (inTop3(msg.sender)) {
                sort();
            } else {
                top3[top3.length - 1] = msg.sender;
                sort();
            }
        }
    }

    //withdraw, only admin can do this
    function withdraw(uint amount) public {
        require(admin[msg.sender], "no access!");
        require(amount <= address(this).balance, "insufficient balance!");
        address payable to = payable(msg.sender);
        to.transfer(amount);
    }

    //in top3 or not
    function inTop3(address addr) private view returns (bool) {
        for (uint i = 0; i < top3.length; i++) {
            if (addr == top3[i]) {
                return true;
            }
        }
        return false;
    }

    //sort top3
    function sort() private {
        for (uint i = top3.length - 1; i >= 1; i--) {
            if (accountBalance[top3[i]] > accountBalance[top3[i - 1]]) {
                address temp = top3[i - 1];
                top3[i - 1] = top3[i];
                top3[i] = temp;
            }
        }
    }
}

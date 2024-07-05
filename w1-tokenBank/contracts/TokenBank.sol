// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenBank {

    //erc20合约
    IERC20 hulioToken;

    constructor(address tokenContractAddress) {
      hulioToken = IERC20(tokenContractAddress);
    }

    mapping(address => uint256) public bankBalance;

    //在调用 deposit 函数之前，用户需要先调用代币合约的 approve 方法授权 TokenBank 合约可以转移代币。
    function deposit(uint256 _amount) public {
        require(_amount <= hulioToken.balanceOf(msg.sender), "insufficient balance.");
        hulioToken.transferFrom(msg.sender, address(this), _amount);
        bankBalance[msg.sender] += _amount;
    }

    function withdraw(uint _amount) public {
        require(_amount <= bankBalance[msg.sender], "insufficient balance.");
        hulioToken.transfer(msg.sender, _amount);
        bankBalance[msg.sender] -= _amount;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
/**
 * erc20代币合约
 */
contract Hulio is ERC20Permit {

    /**
     * 构造函数
     */
    constructor() ERC20("Hulio", "HU") ERC20Permit("Hulio") {}

    /**
     * mint, 暂时允许所有人挖
     */
    function mint() external {
        _mint(msg.sender, 10 ** 9);
    }
    
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
/**
 * erc20代币合约
 */
contract Hulio721 is ERC721 {
    constructor() ERC721("Hulio", "HU") {}

    function freeMint(uint256 tokenId) public {
        _mint(msg.sender, tokenId);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RoboNFT is Ownable, ERC721 {

    //token ipfs前缀
    string private tokenUriPreFix;

    //nft id to owner address; we use REC721 _owners

    //address to nft count; we use ERC7212 _balances

    constructor(
        string memory _tokenUriPrefix,
        string memory _name,
        string memory _symbol
    ) Ownable(msg.sender) ERC721(_name, _symbol) {
        tokenUriPreFix = _tokenUriPrefix;
    }

    //mint
    function createNft(uint256 _robotId) public onlyOwner() {
        //ERC721 mint
        _safeMint(msg.sender, _robotId);
    }

    function tokenURI(uint256 _robotId) public view override returns (string memory) {
        // Implement your own token URI logic here
        return string(abi.encodePacked(tokenUriPreFix, _robotId));
    }

    function setTokenUriPrefix(string memory _newPrefix) public onlyOwner {
        tokenUriPreFix = _newPrefix;
    }
}
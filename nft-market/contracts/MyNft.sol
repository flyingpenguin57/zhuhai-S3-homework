// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyNFT is Ownable, ERC721 {

    using Strings for uint256;

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
    function createNft(uint256 _tokenId) public onlyOwner() {
        //ERC721 mint
        _safeMint(msg.sender, _tokenId);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        string memory _valueAsString = _tokenId.toString();
        return string(abi.encodePacked(tokenUriPreFix, _valueAsString));
    }

    function setTokenUriPrefix(string memory _newPrefix) public onlyOwner {
        tokenUriPreFix = _newPrefix;
    }
}
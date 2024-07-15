// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AirDropNFTMarket is IERC721Receiver {
    IERC20 private hulioToken;
    address private hulioTokenAddr;
    IERC721 private hulioNFT;
    address private hulioNFTAddr;
    bytes32 public merkelRootHash;

    function setMerkelRootHahs(bytes32 rootHash) public {
        merkelRootHash = rootHash;
    }

    constructor(address _hulioTokenAddr, address _hulioNFTAddr) {
        hulioTokenAddr = _hulioTokenAddr;
        hulioToken = IERC20(_hulioTokenAddr);
        hulioNFT = IERC721(_hulioNFTAddr);
        hulioNFTAddr = _hulioNFTAddr;
    }

    //出售信息
    struct SaleInfo {
        address nft; //nft合约地址
        uint nftId; //nft id
        uint priceInHulioToken; //价格，只能用我们的token计价和交易
    }

    //市场，存放出售信息
    SaleInfo[] public market;

    //nft合约地址 -> nft id ->市场中的id
    mapping(address => mapping(uint256 => uint256)) public nftInfoToMarketId;
    //nft合约地址 -> nft id ->卖家地址
    mapping(address => mapping(uint => address)) public nftInfoToSalerAccount;

    //上架
    //当用户在erc721合约中，把nft转到market合约账户下时，会调用这个函数
    function onERC721Received(
        address /* operator */,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        //判断是否上架
        address saler = nftInfoToSalerAccount[msg.sender][tokenId];
        require(saler == address(0), "already in sale.");
        market.push(SaleInfo(msg.sender, tokenId, bytesToUint(data)));
        nftInfoToMarketId[msg.sender][tokenId] = market.length - 1;
        nftInfoToSalerAccount[msg.sender][tokenId] = from;
        return IERC721Receiver.onERC721Received.selector;
    }

    //下架
    function unsale(address nftAddr, uint nftId) public {
        //判断是否上架
        address saler = nftInfoToSalerAccount[nftAddr][nftId];
        require(saler != address(0), "nft is not in sale.");
        //判断是否是nft的所有者
        require(msg.sender == saler, "Not your nft.");

        //把最后一个商品放到要下架的商品的位置，把最后一个商品弹出
        uint marketId = nftInfoToMarketId[nftAddr][nftId];
        SaleInfo memory saleInfo = market[market.length - 1];
        market[marketId] = saleInfo;
        market.pop();
        //更新最后一个商品对应的market id
        nftInfoToMarketId[saleInfo.nft][saleInfo.nftId] = marketId;
        //把要下架的商品对应的account设为0地址
        nftInfoToSalerAccount[nftAddr][nftId] = address(0);

        //把nft从market的账户下转回给saler
        IERC721 nftContract = IERC721(nftAddr);
        nftContract.safeTransferFrom(address(this), saler, nftId);
    }

    //空投用户优惠购买
    function airDropBuy(
        address nftAddr,
        uint256 nftId,
        bytes32[] memory proof,
        bool[] memory left,
        bytes32 leaf
    ) public {

        //check merkel hash
        verify(proof, left, leaf);

        require(1==2,"hahaha");

        //get sale info
        uint256 marketIndex = nftInfoToMarketId[nftAddr][nftId];
        SaleInfo memory saleInfo = market[marketIndex];

        //erc20 approve
        bytes memory invokeData = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            saleInfo.priceInHulioToken / 2
        );
        (bool success, ) = hulioTokenAddr.delegatecall(invokeData);
        require(success, "approve erc20 fail");

        //pay token
        address saler = nftInfoToSalerAccount[nftAddr][nftId];
        hulioToken.transferFrom(
            msg.sender,
            saler,
            saleInfo.priceInHulioToken / 2
        );

        //get nft
        IERC721(nftAddr).safeTransferFrom(address(this), msg.sender, nftId);
    }

    function bytesToUint(bytes memory data) private pure returns (uint256) {
        uint256 result;
        assembly {
            result := mload(add(data, 32))
        }
        return result;
    }

    function bytesToAddrAndUint(
        bytes memory data
    ) public pure returns (address, uint256) {
        // 使用 abi.decode 从 data 中解析出 address 和 uint256
        (address addr, uint256 value) = abi.decode(data, (address, uint256));
        return (addr, value);
    }

    // 验证叶子节点和证明是否能生成正确的 Merkle 树根哈希
    function verify(
        bytes32[] memory proof,
        bool[] memory left,
        bytes32 leaf
    ) public view {
        bytes32 computedHash = leaf;

        bytes32[10] memory v;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (left[i]) {
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
                v[i] = computedHash;
            } else {
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
                v[i] = computedHash;
            }
        }
        require(computedHash == merkelRootHash, "not air drop user.");
        //revert MyError(leaf, leaf, v);
    }

    error MyError(bytes32 v1,bytes32 v2, bytes32[10] v3);
}

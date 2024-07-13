
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract MyNftMarket is IERC721Receiver, IERC1363Receiver {

    IERC20 hulioToken;

    constructor(address hulioTokenAddr) {
        hulioToken = IERC20(hulioTokenAddr);
    }

    //出售信息
    struct SaleInfo {
        address nft; //nft合约地址
        uint nftId;  //nft id
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
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) override external returns (bytes4) {
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
        require( saler != address(0), "nft is not in sale.");
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

    //购买
    function onTransferReceived(
        address operator,
        address from,
        uint256 amount,
        bytes memory data
    ) external returns (bytes4) {
        //0.判断msg.sender == HulioToken的地址；我们只接受HulioToken购买;省略，不做了
        //1.从data中解析 nft address and nft id
        address nftAddr;
        uint256 nftId;
        (nftAddr, nftId) = bytesToAddrAndUint(data);
        //2.判断是否上架
        address saler = nftInfoToSalerAccount[nftAddr][nftId];
        require( saler != address(0), "nft is not in sale.");
        SaleInfo memory curSaleInfo = market[nftInfoToMarketId[nftAddr][nftId]];
        require(amount >= curSaleInfo.priceInHulioToken, "please pay enough moneny");
        //3.把最后一个商品放到要下架的商品的位置，把最后一个商品弹出
        uint marketId = nftInfoToMarketId[nftAddr][nftId];
        SaleInfo memory saleInfo = market[market.length - 1];
        market[marketId] = saleInfo;
        market.pop();
        
        nftInfoToMarketId[saleInfo.nft][saleInfo.nftId] = marketId;
        nftInfoToSalerAccount[nftAddr][nftId] = address(0);

        //4.把nft从market的账户下转给buyer
        IERC721 nftContract = IERC721(nftAddr);
        nftContract.safeTransferFrom(address(this), from, nftId);

        //5.把钱转给卖货的人
        hulioToken.transfer(saler, amount);

        return IERC1363Receiver.onTransferReceived.selector;
    }

    function bytesToUint(bytes memory data) private pure returns (uint256) {
        uint256 result;
        assembly {
            result := mload(add(data, 32))
        }
        return result;
    }    

    function bytesToAddrAndUint(bytes memory data) public pure returns (address, uint256) {
        // 使用 abi.decode 从 data 中解析出 address 和 uint256
        (address addr, uint256 value) = abi.decode(data, (address, uint256));
        return (addr, value);
    }
}

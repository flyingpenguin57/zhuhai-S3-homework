// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title RenftMarket
 * @dev NFT租赁市场合约
 *   TODO:
 *      1. 退还NFT：租户在租赁期内，可以随时退还NFT，根据租赁时长计算租金，剩余租金将会退还给出租人
 *      2. 过期订单处理：
 *      3. 领取租金：出租人可以随时领取租金
 */
contract NFTRentMarket is EIP712 {
    //结构化签名数据结构hash
    bytes32 private constant BORROW_TYPEHASH =
        keccak256(
            "Borrow(address maker,address nft_ca,uint256 token_id,uint256 daily_rent,uint256 max_rental_duration,uint256 min_collateral,uint256 list_endtime)"
        );

    // 出租订单事件
    event BorrowNFT(
        address indexed taker,
        address indexed maker,
        bytes32 orderHash,
        uint256 collateral //抵押的eth数量
    );
    // 取消订单事件
    event OrderCanceled(address indexed maker, bytes32 orderHash);

    //nft已经在租赁中，不能重复租赁
    error nftInRent(address ca, uint256 tokenId);

    error ERC2612InvalidSigner(address signer, address maker);

    BorrowOrder[] public borrowOrders; //存放租赁订单;
    mapping(bytes32 => uint256) public orderToIndex; // order to index

    constructor() EIP712("NFTRentMarket", "1") {
        //0初始被一个无效数据占用，这样可以通过orderToIndex == 0来判断nft租赁是否存在
        borrowOrders.push(BorrowOrder(address(0),0,0,RentoutOrder(address(0),address(0),0,0,0,0,0)));
    }

    /**
     * @notice 租赁NFT
     * @dev 验证签名后，将NFT从出租人转移到租户，并存储订单信息
     */
    function borrow(
        address v1,
        address v2, 
        uint256 v3,
        uint256 v4,
        uint256 v5,
        uint256 v6,
        uint256 v7,
        bytes calldata makerSignature
    ) external payable {

        RentoutOrder memory order = RentoutOrder(v1,v2,v3,v4,v5,v6,v7);

        //1.验证签名
        checkSignature(order, makerSignature);

        //2.获取order hash
        bytes32 orderhash = orderHash(order);

        //3.判断该token是否已经在出租中
        uint256 orderIndex = orderToIndex[orderhash];
        if (orderIndex != 0) {
            //不能出租，因为上次的出租订单还没有结束
            revert nftInRent(
                order.nft_ca,
                order.token_id
            );
        }

        //4.判断抵押金额是否足够
        require(msg.value >= order.min_collateral, "collateral not enough");
        require(block.timestamp <= order.list_endtime, "list end");

        //5.判读该nft是不是属于maker
        // require(
        //     IERC721(order.nft_ca).ownerOf(order.token_id) ==
        //         order.maker,
        //     "not maker's nft"
        // );

        //6.租赁订单入库
        BorrowOrder memory newBorrowOrder = BorrowOrder({
            taker: msg.sender,
            collateral: msg.value,
            start_time: block.timestamp,
            rentinfo: order
        });
        borrowOrders.push(newBorrowOrder);
        orderToIndex[orderhash] = borrowOrders.length - 1;

        //7.发送事件
        emit BorrowNFT(msg.sender, order.maker, orderhash, msg.value);
    }

    /**
     * 租客归还同时结束订单 或者 到期时出租人结束订单；如果到期没有归还，会接着计算租金，从押金里面扣
     * 1. 取消时一定要将取消的信息在链上标记，防止订单被使用！
     * 2. 防DOS： 取消订单有成本，这样防止随意的挂单，
     */
    function cancelOrder(address ca, uint256 tokenId) external {
        bytes32 orderhash = _orderHash(ca, tokenId);
        uint256 orderIndex = orderToIndex[orderhash];
        require(orderIndex != 0, "nft not in rent");
        BorrowOrder memory borrowOrder = borrowOrders[orderIndex];

        require(msg.sender == borrowOrder.rentinfo.maker || msg.sender == borrowOrder.taker);

        //出租人结束订单
        if (msg.sender == borrowOrder.rentinfo.maker) {
            //没到时间不能结束
            require(
                block.timestamp > borrowOrder.rentinfo.max_rental_duration,
                "not reach end time"
            );
        }
        orderToIndex[orderhash] = 0;
        BorrowOrder memory lastOrder = borrowOrders[borrowOrders.length - 1];
        borrowOrders[orderIndex] = lastOrder;
        borrowOrders.pop();
        orderToIndex[orderHash(lastOrder.rentinfo)] = orderIndex;
        delete orderToIndex[orderhash];

        //计算租金
        uint256 rents = borrowOrder.rentinfo.daily_rent *
            ((block.timestamp - borrowOrder.start_time) / (24 * 60 * 60));

        address payable maker = payable(borrowOrder.rentinfo.maker);
        address payable taker = payable(borrowOrder.taker);
        if (rents >= borrowOrder.collateral) {
            maker.transfer(borrowOrder.collateral);
        } else {
            maker.transfer(rents);
            taker.transfer(borrowOrder.collateral - rents);
        }
    }

    // 计算订单哈希
    function orderHash(
        RentoutOrder memory order
    ) public pure returns (bytes32) {
        return _orderHash(order.nft_ca, order.token_id);
    }

    function _orderHash(
        address ca, uint256 tokenId
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(ca, tokenId));
    }

    //验证签名
    function checkSignature(
        RentoutOrder memory order,
        bytes memory _signature
    ) internal view {
        bytes32 structHash = keccak256(
            abi.encode(
                BORROW_TYPEHASH,
                order.maker,
                order.nft_ca,
                order.token_id,
                order.daily_rent,
                order.max_rental_duration,
                order.min_collateral,
                order.list_endtime
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != order.maker) {
            revert ERC2612InvalidSigner(signer, order.maker);
        }
    }

    struct RentoutOrder {
        address maker; // 出租方地址
        address nft_ca; // NFT合约地址
        uint256 token_id; // NFT tokenId
        uint256 daily_rent; // 每日租金
        uint256 max_rental_duration; // 最大租赁时长
        uint256 min_collateral; // 最小抵押
        uint256 list_endtime; // 挂单结束时间
    }

    // 租赁信息
    struct BorrowOrder {
        address taker; // 租方人地址
        uint256 collateral; // 抵押
        uint256 start_time; // 租赁开始时间，方便计算利息
        RentoutOrder rentinfo; // 租赁订单
    }
}

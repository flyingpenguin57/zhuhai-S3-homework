// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/AirDropNFTMarket.sol";

contract MerkleTreeVerifierTest is Test {
    AirDropNFTMarket verifier;

    // 设置测试数据
    bytes32 root = 0xa7c9712255ae0c0dbaaf0cff398075cafe09d5d9a1fd405ba5fdf86528c4a3d4;
    bytes32 proof1 = 0x5931b4ed56ace4c46b68524cb5bcbf4195f1bbaacbe5228fbd090546c88dd229;
    bytes32 proof2 = 0x5335f0b1680f89ae05164481d633cbcba85596edc804945926275d50a01f0dff;
    bytes32 leaf = 0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb;

    bytes32[] proof = [proof1,proof2];
    bool[] left = [true, false];

    address nftAddr = 0xddaAd340b0f1Ef65169Ae5E41A8b10776a75482d;
    uint256 nftId = 1;

    function setUp() public {
        verifier = new AirDropNFTMarket(0xddaAd340b0f1Ef65169Ae5E41A8b10776a75482d,0xddaAd340b0f1Ef65169Ae5E41A8b10776a75482d);
    }

    function testVerifyIncorrectProof() public {
        vm.prank(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        verifier.setMerkelRootHahs(root);
                vm.prank(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);

        verifier.airDropBuy(nftAddr, nftId, proof, left, leaf);
    }
}

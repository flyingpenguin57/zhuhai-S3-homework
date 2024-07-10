// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Hulio} from "../src/Hulio.sol";

contract BankTest is Test {
    Hulio public hulio;
    address private user1;
    address private user2;


    function setUp() public {
        hulio = new Hulio();
        user1 = address(0x123);
        user2 = address(0x456);
        vm.deal(user1, 10 ether);
    }

    function testMint() public {
        vm.prank(user1);
        hulio.mint();
        console.log(hulio.balanceOf(user1));
    }
}

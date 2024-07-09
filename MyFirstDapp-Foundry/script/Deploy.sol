// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/Hulio.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        
        // 部署你的合约
        Hulio myToken = new Hulio();
        
        vm.stopBroadcast();
    }
}
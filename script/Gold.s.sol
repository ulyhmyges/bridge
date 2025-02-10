// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";
import {Gold} from "../src/Gold.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";


contract GoldScript is Script {
    Gold public gold;
    address public wallet;
    address public account;
    address public USER = address(0x57);

    function setUp() public {
        wallet = address(vm.envAddress("WALLET"));
        account = address(vm.envAddress("ACCOUNT"));
    }

    function run() public {
        vm.startBroadcast(wallet);
        gold = new Gold(50*10**18, wallet); // 50 GT
        
        console.log(gold.balanceOf(wallet));
        
        console.log(USER.balance);
        console.log("USER tokens: ", gold.balanceOf(account));
        console.log(gold.getGDZ(1000));
        console.log(wallet.balance); // O.996131515142992556 Sepolia ETH
        console.log("wallet tokens: ", gold.balanceOf(wallet));
        
        //console.log(gold.getGolds(100*10**18));
    }
}
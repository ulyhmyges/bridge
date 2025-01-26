// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";
import {Gold} from "../src/Gold.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";


contract GoldScript is Script {
    Gold public gold;
    address public wallet;

    function setUp() public {
        wallet = address(vm.envAddress("WALLET_ADDRESS"));
        console.log("wallet: ", wallet);
    }

    function run() public {

        gold = new Gold(50*10**18, wallet); // 50 GT
        console.log(gold.getPriceGT());
        
        console.log(gold.balanceOf(wallet));
        console.log(gold.getGDZ(1000));
        //console.log(gold.getGolds(100*10**18));
    }
}
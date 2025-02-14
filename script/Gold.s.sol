// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";
import {Gold} from "../src/Gold.sol";
import {Lottery} from "../src/Lottery.sol";

contract GoldScript is Script {
    Gold public gold;
    Lottery public lottery;
    address public wallet;
    address public account;
    uint256 public subscriptionId = 90256203075644519698193909098372117001279731851240498108137329860284191118063;

    function setUp() public {
        wallet = address(vm.envAddress("WALLET"));
        account = address(vm.envAddress("ACCOUNT"));
    }

    function run() public {
        vm.startBroadcast(wallet);
        lottery = new Lottery(subscriptionId);
        gold = new Gold(50*10**18, wallet, address(lottery)); // 50 GT
        
        // check balance 
        console.log("USER tokens : ", gold.balanceOf(account), " GDZ");
        console.log("Wallet tokens: ", gold.balanceOf(wallet), "GDZ");

        // buy one GT token
      
        vm.stopBroadcast();
    }
}
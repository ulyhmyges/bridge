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

    function setUp() public {
        wallet = address(vm.envAddress("WALLET"));
        account = address(vm.envAddress("ACCOUNT"));
    }

    function run() public {
        vm.startBroadcast(wallet);
        gold = new Gold(50*10**18, wallet, address(lottery)); // 50 GT
        
        // check balance 
        console.log("USER tokens : ", gold.balanceOf(account), " GDZ");

        // buy one GT token
      
        (bool success, ) = address(gold).call{value: 0.03555 ether}(abi.encodeWithSignature("safeMint(address)", account));
        console.log(success);

        // check balance of account 
        console.log("USER tokens : ", gold.balanceOf(account), " GDZ"); // 1.013010005377997198e18

        // wallet balance
        console.log(wallet.balance); // O.996131515142992556 Sepolia ETH
        console.log("wallet tokens: ", gold.balanceOf(wallet)); // 50000000000000000000
        vm.stopBroadcast();
    }
}
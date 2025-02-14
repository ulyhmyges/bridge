// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";
import {Gold} from "../src/Gold.sol";
import {Lottery} from "../src/Lottery.sol";

contract LotteryScript is Script {
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
        lottery = Lottery(payable(0xE95cafFE9A77a92327Bd649fe85E8F9059491474));
        gold = Gold(payable(0xa9Ef1f18d9ccceD2c124E6F41DB80BcDA89ec120));

        // check balance 
        console.log("wallet tokens : ", gold.balanceOf(wallet), " GDZ");

        (bool success, ) = address(gold).call{value: 0.0000055 ether}(abi.encodeWithSignature("safeMint(address)", wallet));
        console.log(success);

        // check balance of account 
        console.log("wallet tokens : ", gold.balanceOf(wallet), " GDZ"); // 1.013010005377997198e18

        console.log(lottery.owner());
        console.log(msg.sender);
        console.log("participant", lottery.getParticipantsCount());

        // wallet balance
        console.log(wallet.balance); // O.996131515142992556 Sepolia ETH

        lottery.requestRandomWinner();
        console.log("wallet tokens: ", gold.balanceOf(account));

        vm.stopBroadcast();
    }
}
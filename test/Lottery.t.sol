// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Gold} from "../src/Gold.sol";
import {Lottery} from "../src/Lottery.sol";



contract LotteryTest is Test {
       
    Gold public gold;
    Lottery public lottery;

    address public USER = address(0x36);
    address public wallet = address(0x99bdA7fd93A5c41Ea537182b37215567e832A726);

    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625; // VRF Coordinator (Sepolia)
    address linkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789; // LINK Token (Sepolia)

    function setUp() public {
        vm.startBroadcast(wallet);
        lottery = new Lottery(1);
        gold = new Gold(50*10**18, wallet, address(lottery));
        deal(USER, 1 ether);
        vm.stopBroadcast();

        // goldTokenMock = new GoldTokenMock(
        //     vrfCoordinator,
        //     linkToken,
        //     0x6c3699283bda56ad74f6b855546325b68d482e983852a5ccba7487b572fcd28c, // Mock keyHash
        //     0.1 ether, // Fee
        //     address(this)
        // );

        // // Ajouter des fonds LINK au contrat pour permettre les appels à requestRandomWinner
        // deal(
        //     0x779877A7B0D9E8603169DdbD7836e478b4624789,
        //     address(goldTokenMock),
        //     1 ether
        // );
    }



    // Test de la loterie
    function testLottery() public {
        // Mint des tokens
    }

    function test_random() public view {
        uint256 r = lottery.getRandomNumber() % 5;
        assertTrue(r == 0 || r == 1 || r == 2 || r == 3 || r == 4, "Random number is not 0, 1, 2, 3 or 4.");
    }

    function test_IsParticipant_false() public view {
        assertFalse(lottery.isParticipant(USER), "Not a participant");
    }


    function test_IsParticipant() public {
        vm.startBroadcast(USER);
        assertEq(0, gold.balanceOf(USER));

        // transaction
        gold.safeMint{value: 1 ether}(USER);

        uint256 len = lottery.getParticipantsCount();
        assertEq(len, 1);
        address sender = lottery.getParticipants()[0];
        assertEq(sender, USER);
        // check balance
        assertTrue(lottery.isParticipant(USER), "Not a participant");
        vm.stopBroadcast();
    }

    function test_SelectWinner() public {
        vm.startBroadcast(USER);
        assertEq(0, gold.balanceOf(USER));

        // transaction
        gold.safeMint{value: 1 ether}(USER);

        uint256 len = lottery.getParticipantsCount();
        assertEq(len, 1);
        address sender = lottery.getParticipants()[0];
        assertEq(sender, USER);
        vm.stopBroadcast();
        // check balance
        assertEq(USER.balance, 0);

        vm.startBroadcast(wallet);
        lottery.selectWinner();
        console.log(USER.balance);
        assertEq(2.5*10**16, USER.balance); // collect 2.5% fees
        vm.stopBroadcast();
    }


    function test_SelectWinner_failed() public {
        vm.startBroadcast(USER);
        assertEq(0, gold.balanceOf(USER));

        // transaction
        gold.safeMint{value: 1 ether}(USER);

        uint256 len = lottery.getParticipantsCount();
        assertEq(len, 1);
        address sender = lottery.getParticipants()[0];
        assertEq(sender, USER);
        // check balance
        assertEq(USER.balance, 0);

        vm.expectRevert();
        lottery.selectWinner();
       
        vm.stopBroadcast();
    }

}

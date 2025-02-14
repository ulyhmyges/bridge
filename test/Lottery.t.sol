// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Gold} from "../src/Gold.sol";
import {Lottery} from "../src/Lottery.sol";



contract LotteryTest is Test {

    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625; // VRF Coordinator (Sepolia)
    address linkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789; // LINK Token (Sepolia)

    function setUp() public {
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
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
//import "@chainlink/contracts/v0.8/vrf/VRFConsumerBase.sol";

import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";

import "forge-std/console.sol";

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


contract Lottery is VRFConsumerBaseV2Plus {

    uint256 s_subscriptionId;
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    bytes32 s_keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 callbackGasLimit = 40000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    uint256 public feePercent = 5;
    uint256 public lotteryPool;
    bytes32 internal keyHash;
    uint256 internal fee;

    address public winner;
    address[] public participants;

    // address public owner;

    constructor(uint256 subscriptionId) VRFConsumerBaseV2Plus(vrfCoordinator) {
        s_subscriptionId = subscriptionId;
    }
    // constructor(uint256 subscriptionId) {
    //     s_subscriptionId = subscriptionId;
    //     owner = msg.sender;
    // }

    // modifier onlyOwner {
    //     require (msg.sender == owner, "Not authorized");
    //     _;
    // }

    receive() external payable {}
    
    fallback() external payable {
        require(msg.data.length == 32, "Invalid calldata length");

        address receivedAddress;
        assembly {
            receivedAddress := calldataload(0)
        }

        add(receivedAddress);
    }

    function getParticipants() public view returns (address[] memory){
        return participants;
    }

    function getParticipantsCount() public view returns (uint256) {
        return participants.length;
    }

    function isParticipant(address _participant) public view returns (bool) {
        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == _participant) {
                return true;
            }
        }
        return false;
    }

    function getRandomNumber() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.prevrandao)));
    }

    function selectWinner() public onlyOwner {
        uint256 index = getRandomNumber() % participants.length;
        winner = participants[index];
        delete participants;
        payable(winner).transfer(address(this).balance);
    }
    

    // Lancer la loterie via Chainlink VRF
    function requestRandomWinner() public returns (uint256 requestId) {
        require(lotteryPool > 0, "Lottery pool is empty");
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
    }

    // Attribution du gagnant via VRF
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        console.log(requestId);
        require(participants.length > 0, "No participants in the lottery");
        uint256 winnerIndex = randomWords[0] % participants.length;
        winner = participants[winnerIndex];
        payable(winner).transfer(lotteryPool); // Transférer le pool au gagnant
        lotteryPool = 0; // Réinitialiser le pool
        delete participants; // Réinitialiser les participants
    }

    function add(address _participant) internal {
        if (isParticipant(_participant)){
            return;
        }

        participants.push(_participant);
    }
}
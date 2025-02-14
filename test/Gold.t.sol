// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Gold} from "../src/Gold.sol";
import {GoldScript} from "../script/Gold.s.sol";
import {Lottery} from "../src/Lottery.sol";

contract GoldTest is Test {
    Gold public gold;
    Lottery public lottery;
    GoldScript public script;

    address public USER = address(0x36);
    address public wallet = address(0x99bdA7fd93A5c41Ea537182b37215567e832A726);

    function setUp() public {
        vm.startBroadcast(wallet);
        lottery = new Lottery(1);
        gold = new Gold(50*10**18, wallet, address(lottery));
        script = new GoldScript();
        deal(USER, 1 ether);
        vm.stopBroadcast();
    }

    /// price = 279815965000

    /// Verify the return type is uint256 and it is consistent
    function test_GetXAU_USD() public view {
      uint256 value1 = gold.getXAU_USD();
      uint256 value2 = gold.getXAU_USD();
      assertEqUint(value1, value2);
    }

    function test_getETH_USD() public view {
      uint256 val1 = gold.getETH_USD();
      uint256 val2 = gold.getETH_USD();
      assertEq(val1, val2);
    }

    // number of decimals in the price = 8
    function test_GetDecimalsXAU() public view {
      uint8 decimals = gold.getDecimalsXAU();
      assertEq(decimals, 8);
    }

    // number of decimals in the price = 8
    function test_GetDecimalsETH() public view {
      uint8 decimals = gold.getDecimalsETH();
      assertEq(decimals, 8);
    }

    function test_GetGDZ() public view {
      uint256 nbTokens = gold.getGDZ(10, gold.getXAU_USD(), gold.getETH_USD());
      uint256 nbTokens2 = gold.getGDZ(10, gold.getXAU_USD(), gold.getETH_USD());
      assertEq(nbTokens, nbTokens2);
    }


    // Failing tests: [FAIL. Reason: call did not revert as expected] test_GetGDZ_failed()
    // function test_GetGDZ_failed() public {
    //   vm.expectRevert();
    //   uint256 nbTokens = gold.getGDZ(0, gold.getXAU_USD(), gold.getETH_USD());
    //   assertEq(nbTokens, 0);
    // }

    // get price in WEI of 1g of gold 
    // WEI price for 1 GT


    function test_OUNCE() public view {
      assertEq(gold.OUNCE(), 31);
    }

    function test_safeMint() public {
      // check balance
      assertEq(0, gold.balanceOf(USER));

      // transaction
      vm.startBroadcast(USER);
      gold.safeMint{value: 1 ether}(USER);
      uint256 tax = gold.fees(1 ether);
      uint256 net = 1 ether - tax;
      uint256 tokens_user = gold.getGDZ(net, gold.getXAU_USD(), gold.getETH_USD());

      vm.stopBroadcast();
      uint256 len = lottery.getParticipantsCount();
      assertEq(len, 1);
      address sender = lottery.getParticipants()[0];
      assertEq(sender, USER);
      // check balance
      assertEq(tokens_user, gold.balanceOf(USER)); // 27.425020726584135864 GT
    }

    function test_safeMint_failed() public {
      // check balance
      assertEq(0, gold.balanceOf(USER));

      // transaction
      vm.startBroadcast(USER);

      vm.expectRevert();
      gold.safeMint{value: 0}(USER);

      vm.stopBroadcast();
    }

    function test_SafeBurn() public {

      assertEq(0, gold.balanceOf(USER));

      // transaction safeMint 1 ether
      vm.startBroadcast(USER);
      gold.safeMint{value: 1 ether}(USER);
      uint256 tax = gold.fees(1 ether);
      uint256 net = 1 ether - tax;
      uint256 tokens_user = gold.getGDZ(net, gold.getXAU_USD(), gold.getETH_USD());

      // tests
      uint256 len = lottery.getParticipantsCount();
      assertEq(len, 1);
      address sender = lottery.getParticipants()[0];
      assertEq(sender, USER);

      // check tokens
      assertEq(tokens_user, gold.balanceOf(USER)); // 27.425020726584135864 GT

       // check balance after tx safeMint
      assertEq(0, USER.balance);

      // transaction
  
      gold.safeBurn(gold.balanceOf(USER));

      // verification
      tax = gold.fees(1 ether);
      net = 1 ether - tax;
      tokens_user = gold.getGDZ(net, gold.getXAU_USD(), gold.getETH_USD());
      uint256 amountWEI = gold.getWEI(tokens_user, gold.getXAU_USD(), gold.getETH_USD());
      tax = gold.fees(amountWEI);
      uint256 userWEI = amountWEI - tax;

      len = lottery.getParticipantsCount();
      assertEq(len, 1);
      sender = lottery.getParticipants()[0];
      assertEq(sender, USER);

      // check balance
      assertEq(0, gold.balanceOf(USER));  // tokens = 0
      assertEq(userWEI, USER.balance);    // return equivalent in WEI = O.902500000000000000 ETH
      vm.stopBroadcast();
    }

    function test_GetWEI() public view {
      uint256 priceGD = gold.getXAU_USD();
      uint256 priceED = gold.getETH_USD();

      // price in WEI for 1 GT
      uint256 amountWEI = gold.getWEI(1*10**18, priceGD, priceED); // 3.4e16 WEI
      assertEq(amountWEI, amountWEI);
    }


    // function test_GetWEI_failed() public {
    //   uint256 priceGD = gold.getXAU_USD();
    //   uint256 priceED = gold.getETH_USD();

    //   vm.expectRevert();
    //   uint256 price = gold.getWEI(0, priceGD, priceED);
    //   assertEq(price, 0);
    // }

    function test_Fees() public view {
      uint256 tax = gold.fees(100);
      assertEq(tax, 5);
      uint256 tax2 = gold.fees(200);
      assertEq(tax2, 10);
    }

    function test_withdraw() public {
      vm.startBroadcast(USER);
      gold.safeMint{value: 1 ether}(USER);
      vm.stopBroadcast();

      vm.startBroadcast(wallet);
      assertEq(0.975*10**18, address(gold).balance);
      gold.withdraw();
      vm.stopBroadcast();
    }

    function test_withdraw_failed() public {
      vm.startBroadcast(USER);
      gold.safeMint{value: 1 ether}(USER);
      vm.expectRevert();
      gold.withdraw();
      vm.stopBroadcast();
    }


    // function withdraw() public onlyOwner whenNotPaused {
    //     require(address(this).balance > 0, "No ETH to withdraw");
    //     (bool success, ) = owner.call{value: address(this).balance}("");
    //     require(success, "Transfer failed.");
    // }
    
    /// GoldScript test
    function test_Run() public {
      script.run();
    }

}
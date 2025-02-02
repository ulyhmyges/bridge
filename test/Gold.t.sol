// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Gold} from "../src/Gold.sol";

contract GoldTest is Test {
    Gold public gold;

    address public USER = address(0x36);
    address public myAddr = address(0x99bdA7fd93A5c41Ea537182b37215567e832A726);

    function setUp() public {
        gold = new Gold(50, myAddr);
    }

    function test_GetPrice() public view {
      console.log(msg.sender);

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
      uint256 nbTokens = gold.getGDZ(10);
      uint256 nbTokens2 = gold.getGDZ(10);
      assertEq(nbTokens, nbTokens2);
    }

    // get price in WEI of 1g of gold 
    // WEI price for 1 GT
    function test_GetPriceGT() public view {
      uint256 price = gold.getPriceGT();
      uint256 price2 = gold.getPriceGT();
      assertEq(price, price2);
    }

    function test_OUNCE() public view {
      assertEq(gold.OUNCE(), 31);
    }
}
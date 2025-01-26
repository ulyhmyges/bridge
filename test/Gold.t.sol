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
      console.log(myAddr);
    }
}
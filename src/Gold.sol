// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract Gold is ERC20 {
    AggregatorV3Interface internal dataFeedXAU;
    AggregatorV3Interface internal dataFeedETH;
    
    // one ounce represents 31 gram of gold
    uint256 public constant OUNCE = 31;
    constructor(uint256 initialSupply, address addr) ERC20 ("Gold", "GT") payable {
        _mint(addr, initialSupply);
        dataFeedXAU = AggregatorV3Interface(
            0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea
        );

        dataFeedETH = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

    }

    /// buy Gold tokens with ETH
    // Mint the number of GDZ from WEI sent to the recipient _to
    /// @param _to recipient
    function safeMint(address _to) payable public {
        uint256 amount = getGDZ(msg.value);
        _mint(_to, amount);
    }

    // get number of GDZ from WEI value
    // 1 GT = 10**18 GDZ
    function getGDZ(uint256 valueWEI) public view returns (uint256) {
        require(valueWEI != 0, "Not enough amount of WEI.");
        uint256 priceGT = getPriceGT() ;
        (bool success, uint256 nbTokens) = Math.tryDiv(valueWEI* 10**18, priceGT);
        require(success, "Error get GODIZ");
        return nbTokens;
    }

    // Sepolia
    // XAU/USD 0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea
    // ETH/USD 0x694AA1769357215DE4FAC081bf1f309aDC325306
    
    // get price in WEI of 1g of gold 
    // WEI price for 1 GT
    function getPriceGT() public view returns (uint256) {
        uint256 priceGold_Dollars = getXAU_USD();
        uint256 priceGold_ETH = getETH_USD() ;
        (bool success, uint256 priceXAU_ETH) = Math.tryDiv(priceGold_Dollars * 10**18, priceGold_ETH * OUNCE);
        require(success, "Error division AUX/ETH");
        return priceXAU_ETH; // 35885249284894932 WEI  (~O.O35ETH/GT)
    }

    /// price = 246227956862
    function getETH_USD() public view returns (uint256) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeedETH.latestRoundData();

        return uint256(price);
    }
    /// return price of once gold with 8 decimals
    /// price = 273914500000
    function getXAU_USD() public view returns (uint256) {
        // prettier-ignore
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeedXAU.latestRoundData();

        return uint256(price);
    }

    // number of decimals in the price = 8
    function getDecimalsXAU() public view returns (uint8) {
        return dataFeedXAU.decimals();
    }


    // number of decimals in the price = 8
    function getDecimalsETH() public view returns (uint8) {
        return dataFeedETH.decimals();
    }
}
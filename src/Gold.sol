// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract Gold is ERC20 {
    AggregatorV3Interface internal dataFeedXAU;
    AggregatorV3Interface internal dataFeedETH;
    
    // one ounce represents 31 gram of gold
    uint256 internal constant OUNCE = 31;
    constructor(uint256 initialSupply) ERC20 ("Gold", "GT") {
        _mint(msg.sender, initialSupply);
        dataFeedXAU = AggregatorV3Interface(
            0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea
        );

        dataFeedETH = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

    }

    /// buy token gold with ETH
    // Number of Gold tokens = value * 31 / (priceXAU/ETH * 10^18) with value in WEI
    /// @param _to recipient
    function safeMint(address _to) payable public {

    }

    /**
     * @dev Returns the number of decimal places used for token display.
     * Typically, ERC20 tokens use 18 decimals, but this implementation 
     * returns 8 decimals instead.
     *
     * @return uint8 The number of decimal places.
     */
    function decimals() public view virtual override returns (uint8) {
        return 8;
    }


    function getGolds(uint256 valueWEI) public view returns (uint256) {
        uint256 priceGold_Dollars = getXAU_USD();
        uint256 priceGold_ETH = getETH_USD() ;
        (bool success, uint256 nbTokens) = Math.tryDiv(valueWEI * priceGold_Dollars, priceGold_ETH * OUNCE * 10**18);
        require(success, "Error getGolds");
        return nbTokens;
    }

    // Sepolia
    // XAU/USD 0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea
    // ETH/USD 0x694AA1769357215DE4FAC081bf1f309aDC325306
    
    // get price in ETH of 1g of gold equivalent of 1 Gold token
    function getPrice() public view returns (uint256) {
        uint256 priceGold_Dollars = getXAU_USD();
        uint256 priceGold_ETH = getETH_USD() ;
        (bool success, uint256 priceXAU_ETH) = Math.tryDiv(priceGold_Dollars, priceGold_ETH * 31);
        require(success, "Error division AUX/ETH");
        return priceXAU_ETH;
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
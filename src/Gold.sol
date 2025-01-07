// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Gold is ERC20 {
    AggregatorV3Interface internal dataFeedXAU;
    AggregatorV3Interface internal dataFeedETH;
    constructor(uint256 initialSupply, string memory name, string memory symbol, address addr) ERC20 (name, symbol) {
        _mint(addr, initialSupply);
        dataFeedXAU = AggregatorV3Interface(
            0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea
        );

        dataFeedETH = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

    }

    /// buy token gold with ETH
    /// @param _to recipient
    function safeMint(address _to) payable public {

    }

    // Sepolia
    // XAU/USD 0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea
    // ETH/USD 0x694AA1769357215DE4FAC081bf1f309aDC325306
    

    function getETH_USD() public view returns (int256) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeedETH.latestRoundData();

        return price;
    }
    /// return price of once gold with 8 decimals
    /// price = 273914500000
    function getXAU_USD() public view returns (int256) {
        // prettier-ignore
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeedXAU.latestRoundData();

        return price;
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
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "../src/Lottery.sol";


contract Gold is ERC20, Pausable{
    AggregatorV3Interface internal dataFeedXAU;
    AggregatorV3Interface internal dataFeedETH;
    
    // one ounce represents 31 gram of gold
    uint256 public constant OUNCE = 31;
    Lottery public lottery ;
    uint256 public totalFees;
    address public owner;
   
    constructor(uint256 _initialSupply, address _addr, address _lottery) ERC20 ("Gold", "GT") {
        _mint(_addr, _initialSupply);
        dataFeedXAU = AggregatorV3Interface(
            0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea
        );

        dataFeedETH = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

        totalFees = 0;
        owner = msg.sender;
        lottery = Lottery(payable(_lottery));
    }

    /// buy Gold tokens with ETH
    // Mint the number of GDZ from WEI sent to the recipient _to
    /// @param _to recipient
    function safeMint(address _to) public payable whenNotPaused  {
        uint256 amountWEI = msg.value;
        uint256 tax = fees(amountWEI);
   
        deposit(tax);
        

        uint256 netWEI = amountWEI - tax;
        uint256 tokens = getGDZ(netWEI, getXAU_USD(), getETH_USD());
    
        _mint(_to, tokens);
    }

    function deposit(uint256 tax) public {
        require(tax !=  0, "Fees must be > 0");
        (bool success, ) = address(lottery).call{value: tax}(abi.encode(msg.sender));
        require(success, "deposit Error: Transfer fees failed.");
    }

    function safeBurn(uint256 gdz) whenNotPaused public {
        address user = msg.sender; 
        uint256 tokens_user = balanceOf(user);
        require(tokens_user >= gdz, "safeBurn Error: Not enough");
        uint256 amountWEI = getWEI(gdz, getXAU_USD(), getETH_USD());
        uint256 tax = fees(amountWEI);

        // deposit fees on Lottery contract
        (bool success, ) = address(lottery).call{value: tax}(""); // need receive or fallback function !!
        require(success, "safeBurn Error: Can not deposit fees");

        // send ETH to user
        uint256 netWEI = amountWEI - tax;
        (bool success_user, ) = user.call{value: netWEI}("");

        require(success_user, "safeBurn Error: Sending ETH to user");
    }

    modifier onlyOwner {
        require(msg.sender == owner, "safeBurn Error: Not authorized.");
        _;
    }

    // need receive or fallback function to the recipient contract
    function withdraw() public onlyOwner whenNotPaused {
        require(address(this).balance > 0, "No ETH to withdraw");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    // This function is executed on a call to the contract if none of the other
    // functions match the given function signature, or if no data is supplied at all
    fallback() external payable {}
    

    // This function is executed when a contract receives plain Ether (without data)
    receive() external payable {}

    function fees(uint256 amount) public pure returns (uint256){
        (, uint256 tax) = Math.tryDiv(amount * 5, 100);
        return tax;
    }

    // get number of GDZ from WEI value
    // 1 GT = 10**18 GDZ
    function getGDZ(uint256 valueWEI, uint256 priceGold_Dollars, uint256 priceETH_Dollars) public pure returns (uint256) {
        require(valueWEI != 0, "Not enough amount of WEI.");
        uint256 priceGT = getWEI(1 ether, priceGold_Dollars, priceETH_Dollars) ;
        (, uint256 nbTokens) = Math.tryDiv(valueWEI * 10**18, priceGT);
        return nbTokens;
    }

    // Sepolia
    // XAU/USD 0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea
    // ETH/USD 0x694AA1769357215DE4FAC081bf1f309aDC325306
    

    // get price in WEI of 1g of gold 
    // WEI price for 1 GT (=> O.035541363575261088e18)
    // 35885249284894932 WEI  (~O.O35ETH/GT)
    function getWEI(uint256 gdz, uint256 priceGold_Dollars, uint256 priceETH_Dollars) public pure returns (uint256) {
        (, uint256 priceXAU_ETH) = Math.tryDiv(priceGold_Dollars * 10**18, priceETH_Dollars * OUNCE);
        (, uint256 amount)= Math.tryDiv(gdz * priceXAU_ETH, 10**18);
        return amount;
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
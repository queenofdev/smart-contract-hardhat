// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Presale is AccessControl, Ownable, Pausable {
    address _tokenPMX;
    AggregatorV3Interface internal priceFeed;
    address private _priceFeedAddress;
    uint256 _tokenPrice = 1;
    mapping(address => uint256) public tokenBalances;
    uint256 public MAX_TOKENS = 3e19;
    uint256 public MIN_TOKENS = 1e18;

    event TokensPurchased(address buyer, uint256 amount);
    /**
     * Token Price in USD
     * Decimals: 8
     */

    /**
     * Network: BSC Mainnet
     * Aggregator: BNB/USD
     * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     */

    /**
     * Network: BSC Testnet
     * Aggregator: BNB/USD
     * Address: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
     */
     
    constructor(address token, address priceFeedAddress) Ownable(msg.sender) {
        _tokenPMX = token;
         _priceFeedAddress = priceFeedAddress;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function swap(uint256 amount) public payable whenNotPaused {
        require(amount >= MIN_TOKENS && amount <= MAX_TOKENS, "Invalid token quantity");
        require(ERC20(_tokenPMX).balanceOf(address(this)) >= amount, "Insufficient {PMX} Token to sale tokens");

        uint256 totalPls = getPlsAmountForPurchase(amount);

        require(msg.value >= totalPls, "Insufficient PLS to purchase tokens");
        
        if (msg.value > totalPls) {
            uint256 refundPls = msg.value - totalPls;
            payable(msg.sender).transfer(refundPls);
        }

        ERC20(_tokenPMX).transfer(msg.sender, amount);
        tokenBalances[msg.sender] += amount;
        emit TokensPurchased(msg.sender, amount);
    }
    
    function withdrawToken(address _addr) public onlyOwner {
        require(ERC20(_tokenPMX).balanceOf(address(this)) > 0, "All tokens have already been sold");
        ERC20(_tokenPMX).transfer(_addr, ERC20(_tokenPMX).balanceOf(address(this)));
    }

    function withdraw(address _receiver) public onlyOwner {
        require(address(this).balance > 0, "Insufficient PLS to withdraw");
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function setTokenPrice(uint256 price) public onlyOwner {
        _tokenPrice = price;
    }

    function getTokenPrice() public view returns (uint256) {
        return _tokenPrice;
    }

    function setMaxTokenAmount(uint256 _amount) public onlyOwner {
        MAX_TOKENS = _amount;
    }

    function setMinTokenAmount(uint256 _amount) public onlyOwner {
        MIN_TOKENS = _amount;
    }

    function getContractTokenAmount() public view returns (uint256) {
        uint256 balance = ERC20(_tokenPMX).balanceOf(address(this));
        return balance;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getCurrentPLSPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        return uint256(price);
    }

    function getPlsAmountForPurchase(uint256 amount) public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        uint256 totalPls = (amount * _tokenPrice ) / uint256(price);
        return totalPls;
    }
    
    function getPriceFeedAddress() public view returns (address) {
        return _priceFeedAddress;
    }
    
    function setPriceFeedAddress(address newAddress) public onlyOwner {
        _priceFeedAddress = newAddress;
        priceFeed = AggregatorV3Interface(newAddress);
    }

    function pause() external onlyOwner {
        super._pause();
    }

    function unpause() external onlyOwner {
        super._unpause();
    }
}

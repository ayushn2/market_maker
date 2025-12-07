// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Pool {
    uint256 totalSupply;
    uint32 slope;

    mapping(address => uint256) public balances;

    constructor(uint256 _totalSupply, uint32 _slope) {
        totalSupply = _totalSupply;
        slope = _slope;
    }

    function sell(uint256 tokens) public{
        totalSupply -= tokens;

        uint256 balance = balances[msg.sender];
        balances[msg.sender] = balance - tokens;

        uint256 ethReturn = calculateSellReturn(tokens);
        
        
        (bool success, ) = payable(msg.sender).call{value: ethReturn}("");
        require(success, "ETH transfer failed");

    }

    function buy() public payable {
        require(msg.value > 0, "Must send ETH to buy tokens");

        uint256 tokensToMint = calculateBuyReturn(msg.value);
        totalSupply += tokensToMint;

        uint256 currentBalance = balances[msg.sender];
        balances[msg.sender] = currentBalance + tokensToMint;
    }

    function calculateSellReturn(uint256 tokens) public view returns (uint256) {
        // Placeholder logic for sell return calculation
        uint256 currentPrice = calculateSellPrice();
        
        return (tokens * currentPrice) / 1e18; //tokens must be in 18 decimals i.e in wei
    }

    function calculateBuyReturn(uint256 depositAmount) public view returns (uint256) {
        // Placeholder logic for buy return calculation
        uint256 currentPrice = calculateTokenPrice();
        return (depositAmount * 1e18) / currentPrice; //tokens must be in 18 decimals i.e in wei
    }

    // A function to calculate token price based on total supply and slope
    function calculateTokenPrice() public view returns (uint256) {
        uint256 temp = (totalSupply * totalSupply)/1e36; // y = mx^2

        return slope * temp;
    }

    // Function to calculate sell price so nobody can pump and dump
    function calculateSellPrice() public view returns (uint256) {
        uint256 newSlope = 3e17; // 0.5 * 1e18
        uint256 temp = (totalSupply * totalSupply)/1e36; // y = mx^2
        return newSlope * temp / 1e18;
    }
}
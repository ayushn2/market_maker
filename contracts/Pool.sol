// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract Pool is ERC20 {

    uint32 slope;


    constructor(uint256 _initialSupply, uint32 _slope) ERC20("Pool Token", "POOL") {
        _mint(msg.sender, _initialSupply);
        slope = _slope;
    }

    function sell(uint256 tokens) public {
        require(balanceOf(msg.sender) >= tokens, "Insufficient token balance to sell");

        // Burn tokens first so totalSupply() reflects the reduced supply
        _burn(msg.sender, tokens);

        // Now compute the ETH to return based on the new (lower) supply
        uint256 ethReturn = calculateSellReturn(tokens);

        require(
            ethReturn <= address(this).balance,
            "Contract has insufficient ETH balance"
        );

        (bool success, ) = payable(msg.sender).call{value: ethReturn}("");
        require(success, "ETH transfer failed");
    }

    function buy() public payable {
        require(msg.value > 0, "Must send ETH to buy tokens");

        uint256 tokensToMint = calculateBuyReturn(msg.value);

        _mint(msg.sender, tokensToMint);
    }

    function calculateSellReturn(uint256 tokens) public view returns (uint256) {
        uint256 currentPrice = calculateSellPrice();
        
        return (tokens * currentPrice) / 1e18; //tokens must be in 18 decimals i.e in wei
    }

    function calculateBuyReturn(uint256 depositAmount) public view returns (uint256) {
        uint256 currentPrice = calculateTokenPrice();
        return (depositAmount * 1e18) / currentPrice; //tokens must be in 18 decimals i.e in wei
    }

    // A function to calculate token price based on total supply and slope
    function calculateTokenPrice() public view returns (uint256) {
        uint256 supply = totalSupply();
        uint256 temp = (supply * supply)/1e36; // y = mx^2

        return slope * temp;
    }

    // Function to calculate sell price so nobody can pump and dump
    function calculateSellPrice() public view returns (uint256) {
        uint256 newSlope = 3e17; // 0.3 * 1e18
        uint256 supply = totalSupply();
        uint256 temp = (supply * supply)/1e36; // y = mx^2
        return newSlope * temp / 1e18;
    }

    receive() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Pool {
    uint256 totalSupply;
    uint32 slope;

    mapping(address => uint256) balances;

    constructor(uint256 _totalSupply, uint32 _slope) {
        totalSupply = _totalSupply;
        slope = _slope;
        
    }
}
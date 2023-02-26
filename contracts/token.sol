// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract rewardToken is ERC20, Ownable{

uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_)ERC20(name_, symbol_){
        _name = name_;
        _symbol = symbol_;
    }
    function mint(address stakeContract, uint _amount) public onlyOwner {
        _mint(stakeContract, _amount);
    }
 }
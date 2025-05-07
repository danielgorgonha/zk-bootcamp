// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Token {
    string private _name = "Bootcamp";
    string private _symbol = "OCG";
    uint8 private _decimals = 18;

    mapping(address => uint256) private balance;
    mapping(address => mapping(address => uint256)) private _allowance;

    function name() public view returns (string memory) {
      return _name;
    }

    function symbol() public view returns (string memory) {
      return _symbol;
    }

    function decimals() public view returns (uint8) {
      return _decimals;
    }
    
    function balanceOf(address account) public view returns (uint256) {
      return balance[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
      balance[msg.sender] -= amount;
      balance[to] += amount;
      return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
      _allowance[msg.sender][spender] = amount;
      return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
      if (_allowance[from][msg.sender] < amount) {
        revert("Allowance is not enough");
      }

      balance[from] -= amount;
      balance[to] += amount;
      _allowance[from][msg.sender] -= amount;
      return true;
    }
    
    function allowance(address owner, address spender) public view returns (uint256) {
      return _allowance[owner][spender];
    }
}
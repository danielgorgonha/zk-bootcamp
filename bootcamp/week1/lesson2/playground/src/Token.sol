// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Token {
    string private _name = "Bootcamp";
    string private _symbol = "OCG";
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    mapping(address => uint256) private balance;
    mapping(address => mapping(address => uint256)) private _allowance;

    // Standard ERC20 events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Mint event
    event Mint(address indexed to, uint256 amount);

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        require(account != address(0), "Token: address zero is not a valid account");
        return balance[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Token: transfer to the zero address");
        require(balance[msg.sender] >= amount, "Token: transfer amount exceeds balance");

        balance[msg.sender] -= amount;
        balance[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "Token: approve to the zero address");
        
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(from != address(0), "Token: transfer from the zero address");
        require(to != address(0), "Token: transfer to the zero address");
        require(balance[from] >= amount, "Token: transfer amount exceeds balance");
        require(_allowance[from][msg.sender] >= amount, "Token: transfer amount exceeds allowance");

        balance[from] -= amount;
        balance[to] += amount;
        _allowance[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view returns (uint256) {
        require(owner != address(0), "Token: owner is the zero address");
        require(spender != address(0), "Token: spender is the zero address");
        return _allowance[owner][spender];
    }

    // Function to mint tokens (for demonstration purposes)
    function mint(address to, uint256 amount) public {
        require(to != address(0), "Token: mint to the zero address");
        require(amount > 0, "Token: mint amount must be greater than zero");

        _totalSupply += amount;
        balance[to] += amount;
        
        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }

    // Function to increase allowance
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0), "Token: spender is the zero address");
        
        _allowance[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    // Function to decrease allowance
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0), "Token: spender is the zero address");
        
        uint256 currentAllowance = _allowance[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Token: decreased allowance below zero");
        
        _allowance[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }
}
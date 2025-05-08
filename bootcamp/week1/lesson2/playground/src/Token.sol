// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Token {
    string private _name = "Bootcamp";
    string private _symbol = "OCG";
    uint8 private _decimals = 18;
    uint256 private _totalSupply;
    uint256 private constant MAX_SUPPLY = 1000000000 * 10**18; // 1 bilhão de tokens

    // Variáveis de controle
    address private _owner;
    bool private _paused;
    uint256 private _mintDelay = 1 days; // Delay para mint
    mapping(address => uint256) private _lastMintTime;
    
    // Roles para controle de acesso
    mapping(address => bool) private _minters;
    mapping(address => bool) private _admins;

    // Mappings principais
    mapping(address => uint256) private balance;
    mapping(address => mapping(address => uint256)) private _allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);
    event Paused(address account);
    event Unpaused(address account);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == _owner, "Token: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(_admins[msg.sender] || msg.sender == _owner, "Token: caller is not an admin");
        _;
    }

    modifier onlyMinter() {
        require(_minters[msg.sender] || msg.sender == _owner, "Token: caller is not a minter");
        _;
    }

    modifier whenNotPaused() {
        require(!_paused, "Token: contract is paused");
        _;
    }

    modifier validAddress(address account) {
        require(account != address(0), "Token: invalid address");
        _;
    }

    // Constructor
    constructor() {
        _owner = msg.sender;
        _admins[msg.sender] = true;
        _minters[msg.sender] = true;
    }

    // Funções de administração
    function transferOwnership(address newOwner) public onlyOwner validAddress(newOwner) {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function addAdmin(address account) public onlyOwner validAddress(account) {
        _admins[account] = true;
        emit AdminAdded(account);
    }

    function removeAdmin(address account) public onlyOwner validAddress(account) {
        _admins[account] = false;
        emit AdminRemoved(account);
    }

    function addMinter(address account) public onlyAdmin validAddress(account) {
        _minters[account] = true;
        emit MinterAdded(account);
    }

    function removeMinter(address account) public onlyAdmin validAddress(account) {
        _minters[account] = false;
        emit MinterRemoved(account);
    }

    function pause() public onlyAdmin {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyAdmin {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    // Funções de visualização
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
    
    function balanceOf(address account) public view validAddress(account) returns (uint256) {
        return balance[account];
    }

    // Funções principais do token
    function transfer(address to, uint256 amount) public whenNotPaused validAddress(to) returns (bool) {
        require(balance[msg.sender] >= amount, "Token: transfer amount exceeds balance");

        balance[msg.sender] -= amount;
        balance[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public whenNotPaused validAddress(spender) returns (bool) {
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public whenNotPaused validAddress(from) validAddress(to) returns (bool) {
        require(balance[from] >= amount, "Token: transfer amount exceeds balance");
        require(_allowance[from][msg.sender] >= amount, "Token: transfer amount exceeds allowance");

        balance[from] -= amount;
        balance[to] += amount;
        _allowance[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view validAddress(owner) validAddress(spender) returns (uint256) {
        return _allowance[owner][spender];
    }

    // Função de mint com timelock e limites
    function mint(address to, uint256 amount) public onlyMinter whenNotPaused validAddress(to) {
        require(amount > 0, "Token: mint amount must be greater than zero");
        require(_totalSupply + amount <= MAX_SUPPLY, "Token: max supply exceeded");
        
        // Verificar timelock
        require(
            block.timestamp >= _lastMintTime[msg.sender] + _mintDelay,
            "Token: mint delay not elapsed"
        );

        _totalSupply += amount;
        balance[to] += amount;
        _lastMintTime[msg.sender] = block.timestamp;
        
        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }

    // Funções de allowance melhoradas
    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused validAddress(spender) returns (bool) {
        uint256 currentAllowance = _allowance[msg.sender][spender];
        _allowance[msg.sender][spender] = currentAllowance + addedValue;
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused validAddress(spender) returns (bool) {
        uint256 currentAllowance = _allowance[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Token: decreased allowance below zero");
        
        _allowance[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    // Funções de consulta adicionais
    function isOwner(address account) public view returns (bool) {
        return account == _owner;
    }

    function isAdmin(address account) public view returns (bool) {
        return _admins[account];
    }

    function isMinter(address account) public view returns (bool) {
        return _minters[account];
    }

    function isPaused() public view returns (bool) {
        return _paused;
    }

    function getMintDelay() public view returns (uint256) {
        return _mintDelay;
    }

    function getLastMintTime(address account) public view returns (uint256) {
        return _lastMintTime[account];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";

contract TokenScript is Script {
    Token public token;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy do contrato
        token = new Token();
        
        // Mint inicial de tokens para o deployer
        uint256 initialSupply = 1000000 * 10**18; // 1 milhão de tokens
        token.mint(msg.sender, initialSupply);
        
        console.log("Token deployed at:", address(token));
        console.log("Initial supply minted:", initialSupply);
        
        vm.stopBroadcast();
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";

contract TokenScript is Script {
    Token public token;

    function setUp() public {}

    function run() public {
        // Carrega a chave privada do ambiente
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deployer address:", deployer);
        console.log("Deployer balance:", deployer.balance);
        
        vm.startBroadcast(deployerPrivateKey);

        // Deploy do contrato
        token = new Token();
        
        // Mint inicial de tokens para o deployer
        uint256 initialSupply = 1000000 * 10**18; // 1 milhão de tokens
        token.mint(deployer, initialSupply);
        
        console.log("Token deployed at:", address(token));
        console.log("Token name:", token.name());
        console.log("Token symbol:", token.symbol());
        console.log("Token decimals:", token.decimals());
        console.log("Initial supply minted:", initialSupply);
        console.log("Deployer token balance:", token.balanceOf(deployer));
        
        vm.stopBroadcast();
    }
}
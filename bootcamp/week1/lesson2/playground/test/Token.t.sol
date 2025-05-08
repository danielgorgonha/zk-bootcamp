// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token public token;
    address public alice = address(1);
    address public bob = address(2);
    address public charlie = address(3);
    address public zeroAddress = address(0);
    uint256 public constant DAY = 1 days;

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

    function setUp() public {
        token = new Token();
        // Advance initial time to allow the first mint
        vm.warp(block.timestamp + DAY);
    }

    // Helper function to advance time before each mint
    function mintAndWait(address to, uint256 amount) internal {
        // Advance time before mint
        vm.warp(block.timestamp + DAY);
        token.mint(to, amount);
    }

    // Roles tests
    function test_InitialRoles() public view {
        assertTrue(token.isOwner(address(this)));
        assertTrue(token.isAdmin(address(this)));
        assertTrue(token.isMinter(address(this)));
    }

    function test_AddAdmin() public {
        vm.expectEmit(true, true, false, false);
        emit AdminAdded(alice);
        token.addAdmin(alice);
        assertTrue(token.isAdmin(alice));
    }

    function test_RemoveAdmin() public {
        token.addAdmin(alice);
        vm.expectEmit(true, true, false, false);
        emit AdminRemoved(alice);
        token.removeAdmin(alice);
        assertFalse(token.isAdmin(alice));
    }

    function test_AddMinter() public {
        vm.expectEmit(true, true, false, false);
        emit MinterAdded(alice);
        token.addMinter(alice);
        assertTrue(token.isMinter(alice));
    }

    function test_RemoveMinter() public {
        token.addMinter(alice);
        vm.expectEmit(true, true, false, false);
        emit MinterRemoved(alice);
        token.removeMinter(alice);
        assertFalse(token.isMinter(alice));
    }

    // Pause tests
    function test_Pause() public {
        vm.expectEmit(true, false, false, false);
        emit Paused(address(this));
        token.pause();
        assertTrue(token.isPaused());
    }

    function test_Unpause() public {
        token.pause();
        vm.expectEmit(true, false, false, false);
        emit Unpaused(address(this));
        token.unpause();
        assertFalse(token.isPaused());
    }

    function test_TransferWhenPaused() public {
        mintAndWait(address(this), 1000);
        token.pause();
        vm.expectRevert("Token: contract is paused");
        token.transfer(alice, 100);
    }

    // Ownership tests
    function test_TransferOwnership() public {
        vm.expectEmit(true, true, false, false);
        emit OwnershipTransferred(address(this), alice);
        token.transferOwnership(alice);
        assertTrue(token.isOwner(alice));
        assertFalse(token.isOwner(address(this)));
    }

    // Mint with timelock tests
    function test_MintTimelock() public {
        // First mint
        mintAndWait(alice, 100);
        
        // Try to mint before delay
        vm.expectRevert("Token: mint delay not elapsed");
        token.mint(alice, 100);
        
        // Advance time beyond delay and mint again
        vm.warp(block.timestamp + DAY);
        token.mint(alice, 100);
        assertEq(token.balanceOf(alice), 200);
    }

    // Max supply limit tests
    function test_MintMaxSupply() public {
        uint256 maxSupply = 1000000000 * 10**18;
        
        // Try to mint more than the max
        vm.expectRevert("Token: max supply exceeded");
        token.mint(alice, maxSupply + 1);
        
        // Minting the max should work
        mintAndWait(alice, maxSupply);
        assertEq(token.totalSupply(), maxSupply);
    }

    // Permission tests
    function test_OnlyOwnerFunctions() public {
        vm.prank(alice);
        vm.expectRevert("Token: caller is not the owner");
        token.transferOwnership(bob);

        vm.prank(alice);
        vm.expectRevert("Token: caller is not the owner");
        token.addAdmin(bob);
    }

    function test_OnlyAdminFunctions() public {
        vm.prank(alice);
        vm.expectRevert("Token: caller is not an admin");
        token.pause();

        vm.prank(alice);
        vm.expectRevert("Token: caller is not an admin");
        token.addMinter(bob);
    }

    function test_OnlyMinterFunctions() public {
        vm.prank(alice);
        vm.expectRevert("Token: caller is not a minter");
        token.mint(bob, 100);
    }

    // Updated basic tests
    function test_Transfer() public {
        mintAndWait(address(this), 1000);
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(this), alice, 100);
        token.transfer(alice, 100);
        assertEq(token.balanceOf(alice), 100);
    }

    function test_Approve() public {
        vm.expectEmit(true, true, true, true);
        emit Approval(address(this), alice, 100);
        token.approve(alice, 100);
        assertEq(token.allowance(address(this), alice), 100);
    }

    function test_TransferFrom() public {
        mintAndWait(address(this), 1000);
        token.approve(alice, 100);
        vm.prank(alice);
        token.transferFrom(address(this), bob, 100);
        assertEq(token.balanceOf(bob), 100);
        assertEq(token.balanceOf(address(this)), 900);
    }

    // Query tests
    function test_GetMintDelay() public view {
        assertEq(token.getMintDelay(), DAY);
    }

    function test_GetLastMintTime() public {
        mintAndWait(alice, 100);
        assertEq(token.getLastMintTime(address(this)), block.timestamp);
    }

    // Updated fuzzing tests
    function testFuzz_Transfer(uint256 amount) public {
        vm.assume(amount <= 1000);
        mintAndWait(address(this), 1000);
        token.transfer(alice, amount);
        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(address(this)), 1000 - amount);
    }

    function testFuzz_Approve(uint256 amount) public {
        token.approve(alice, amount);
        assertEq(token.allowance(address(this), alice), amount);
    }

    function testFuzz_TransferFrom(uint256 amount) public {
        vm.assume(amount <= 1000);
        mintAndWait(address(this), 1000);
        token.approve(alice, amount);
        vm.prank(alice);
        token.transferFrom(address(this), bob, amount);
        assertEq(token.balanceOf(bob), amount);
        assertEq(token.balanceOf(address(this)), 1000 - amount);
    }
}
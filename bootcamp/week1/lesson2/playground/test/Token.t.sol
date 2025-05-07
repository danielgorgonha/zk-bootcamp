// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token public token;
    address public alice = address(1);
    address public bob = address(2);
    address public zeroAddress = address(0);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);

    function setUp() public {
        token = new Token();
        token.mint(address(this), 1000); // Mint initial tokens for testing
    }

    function test_Name() public view {
        assertEq(token.name(), "Bootcamp");
    }

    function test_Symbol() public view {
        assertEq(token.symbol(), "OCG");
    }

    function test_Decimals() public view {
        assertEq(token.decimals(), 18);
    }

    function test_TotalSupply() public view {
        assertEq(token.totalSupply(), 1000);
    }

    function test_BalanceOf() public view {
        assertEq(token.balanceOf(address(this)), 1000);
    }

    function test_BalanceOf_ZeroAddress() public {
        vm.expectRevert("Token: address zero is not a valid account");
        token.balanceOf(zeroAddress);
    }

    function test_Transfer() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(this), alice, 100);
        token.transfer(alice, 100);
        assertEq(token.balanceOf(alice), 100);
    }

    function test_Transfer_ZeroAddress() public {
        vm.expectRevert("Token: transfer to the zero address");
        token.transfer(zeroAddress, 100);
    }

    function test_Transfer_InsufficientBalance() public {
        vm.expectRevert("Token: transfer amount exceeds balance");
        token.transfer(alice, 1001);
    }

    function test_Approve() public {
        vm.expectEmit(true, true, true, true);
        emit Approval(address(this), alice, 100);
        token.approve(alice, 100);
        assertEq(token.allowance(address(this), alice), 100);
    }

    function test_Approve_ZeroAddress() public {
        vm.expectRevert("Token: approve to the zero address");
        token.approve(zeroAddress, 100);
    }

    function test_TransferFrom() public {
        token.approve(alice, 100);
        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(this), bob, 100);
        token.transferFrom(address(this), bob, 100);
        assertEq(token.balanceOf(bob), 100);
        assertEq(token.balanceOf(address(this)), 900);
    }

    function test_TransferFrom_ZeroAddress() public {
        token.approve(alice, 100);
        vm.prank(alice);
        vm.expectRevert("Token: transfer to the zero address");
        token.transferFrom(address(this), zeroAddress, 100);
    }

    function test_TransferFrom_InsufficientAllowance() public {
        token.approve(alice, 100);
        vm.prank(alice);
        vm.expectRevert("Token: transfer amount exceeds allowance");
        token.transferFrom(address(this), bob, 101);
    }

    function test_TransferFrom_InsufficientBalance() public {
        token.approve(alice, 1001);
        vm.prank(alice);
        vm.expectRevert("Token: transfer amount exceeds balance");
        token.transferFrom(address(this), bob, 1001);
    }

    function test_Mint() public {
        vm.expectEmit(true, true, true, true);
        emit Mint(alice, 100);
        vm.expectEmit(true, true, true, true);
        emit Transfer(zeroAddress, alice, 100);
        token.mint(alice, 100);
        assertEq(token.balanceOf(alice), 100);
        assertEq(token.totalSupply(), 1100);
    }

    function test_Mint_ZeroAddress() public {
        vm.expectRevert("Token: mint to the zero address");
        token.mint(zeroAddress, 100);
    }

    function test_Mint_ZeroAmount() public {
        vm.expectRevert("Token: mint amount must be greater than zero");
        token.mint(alice, 0);
    }

    function test_IncreaseAllowance() public {
        token.approve(alice, 100);
        vm.expectEmit(true, true, true, true);
        emit Approval(address(this), alice, 200);
        token.increaseAllowance(alice, 100);
        assertEq(token.allowance(address(this), alice), 200);
    }

    function test_DecreaseAllowance() public {
        token.approve(alice, 200);
        vm.expectEmit(true, true, true, true);
        emit Approval(address(this), alice, 100);
        token.decreaseAllowance(alice, 100);
        assertEq(token.allowance(address(this), alice), 100);
    }

    function test_DecreaseAllowance_BelowZero() public {
        token.approve(alice, 100);
        vm.expectRevert("Token: decreased allowance below zero");
        token.decreaseAllowance(alice, 101);
    }

    function testFuzz_Transfer(uint256 amount) public {
        vm.assume(amount <= 1000);
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(this), alice, amount);
        token.transfer(alice, amount);
        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(address(this)), 1000 - amount);
    }

    function testFuzz_Approve(uint256 amount) public {
        vm.expectEmit(true, true, true, true);
        emit Approval(address(this), alice, amount);
        token.approve(alice, amount);
        assertEq(token.allowance(address(this), alice), amount);
    }

    function testFuzz_TransferFrom(uint256 amount) public {
        vm.assume(amount <= 1000);
        token.approve(alice, amount);
        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(this), bob, amount);
        token.transferFrom(address(this), bob, amount);
        assertEq(token.balanceOf(bob), amount);
        assertEq(token.balanceOf(address(this)), 1000 - amount);
    }
}
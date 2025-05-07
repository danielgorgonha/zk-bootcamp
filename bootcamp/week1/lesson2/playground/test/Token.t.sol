// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token public token;

    function setUp() public {
      token = new Token();
      deal(address(token), address(this), 1000); // Set initial balance for testing
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

    function test_BalanceOf() public view {
      assertEq(token.balanceOf(address(this)), 1000);
    }

    function test_Transfer() public {
      token.transfer(address(1), 100);
      assertEq(token.balanceOf(address(1)), 100);
    }

    function test_Approve() public {
      token.approve(address(1), 100);
      assertEq(token.allowance(address(this), address(1)), 100);
    }

    function test_TransferFrom() public {
      token.approve(address(1), 100);
      vm.prank(address(1));
      token.transferFrom(address(this), address(1), 100);
      assertEq(token.balanceOf(address(1)), 100);
      assertEq(token.balanceOf(address(this)), 900);
    }

    function test_Allowance() public {
      token.approve(address(1), 100);
      assertEq(token.allowance(address(this), address(1)), 100);
    } 

    function test_TransferFrom_AllowanceNotEnough() public {
      token.approve(address(1), 100);
      vm.expectRevert("Allowance is not enough");
      token.transferFrom(address(this), address(1), 101);
    }

    function test_TransferFrom_SenderNotEnoughBalance() public {
      token.approve(address(1), 1000);
      vm.prank(address(1));
      vm.expectRevert("Allowance is not enough");
      token.transferFrom(address(this), address(1), 1001);
    }

    function test_TransferFrom_ReceiverNotEnoughBalance() public {
      token.approve(address(1), 1000);
      vm.prank(address(1));
      vm.expectRevert("Allowance is not enough");
      token.transferFrom(address(this), address(1), 1001);
    }   

    function testFuzz_Transfer(uint256 amount) public {
        vm.assume(amount <= 1000); // You can't transfer more than the starting balance
        token.transfer(address(1), amount);
        assertEq(token.balanceOf(address(1)), amount);
        assertEq(token.balanceOf(address(this)), 1000 - amount);
    }

    function testFuzz_Approve(uint256 amount) public {
        token.approve(address(1), amount);
        assertEq(token.allowance(address(this), address(1)), amount);
    }

    function testFuzz_TransferFrom(uint256 amount) public {
        vm.assume(amount <= 1000); // You can't transfer more than the starting balance
        token.approve(address(1), amount);
        vm.prank(address(1));
        token.transferFrom(address(this), address(1), amount);
        assertEq(token.balanceOf(address(1)), amount);
        assertEq(token.balanceOf(address(this)), 1000 - amount);
        assertEq(token.allowance(address(this), address(1)), 0);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {FundMe} from "../src/FundMe.sol";
import {Test} from "forge-std/Test.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {

	FundMe fundMe;
	DeployFundMe deployFundMe;
	address constant USER1 = address(1);
	uint256 ethPrice;
	uint256 SEND_AMOUNT = 1 ether;

	function setUp() external{
		// deploy the FundMe contract
		deployFundMe = new DeployFundMe();
		fundMe = FundMe(deployFundMe.run());
	}

	// Check that the depoloyment has gone well
	function testDeploymentValues() public {
		assertEq(fundMe.MIN_USD_DEPOSIT(), 50 ether);
		assertEq(fundMe.getOwner(), msg.sender);
		assertEq(fundMe.getOracle(), deployFundMe.oracle());
	}

	// Test for reverts when depositing and make a correct deposit
	// Each deposit is checked for its correctness in the _deposit internal function
	function testDeposit() public {
		//Depositing with zero native token should revert
		vm.expectRevert(bytes("msg.value cannot be zero"));
		fundMe.fundContract(); 

		//Depositing with a small amount should revert
		vm.expectRevert(bytes("Not enough deposit amount"));
		fundMe.fundContract{value: 0.001 ether}();  

		// Do a deposit of 0.025 eth (equals to 50 usd)
		_deposit(USER1, SEND_AMOUNT);

		//Do one more deposit and make sure the user balance is doubled.
		_deposit(USER1, SEND_AMOUNT);
	}

	// Try to send funds directly to the contract. Must revert
	function testDepositViaReceive() public {
		hoax(USER1);
		vm.expectRevert();
		(bool success, ) = address(fundMe).call{value: SEND_AMOUNT}("");
		require(success);
	}

	// Try to send funds with a non-exisitng function. Must revert
	function testDepositViaFallback() public {
		hoax(USER1);
		vm.expectRevert();
		(bool success, ) = address(fundMe).call{value: SEND_AMOUNT}(abi.encodeWithSignature("doesNotExist()"));
		require(success);
	}

	// deposit and check if the userList array and the balances are correctly set.
	// Check for view functions are also performed here.
	function testGetListOfUsers() public {
		// Do some deposit
		_deposit(address(1), SEND_AMOUNT);
		// Do some deposit
		_deposit(address(2), SEND_AMOUNT*2);
		// Do some more deposit by the same user
		_deposit(address(2), SEND_AMOUNT*5);
		// Do some deposit
		_deposit(address(3), SEND_AMOUNT*3);

		address[] memory userList;
		userList = fundMe.getUserList();
		assertEq(userList.length, 3);
		assertEq(userList[0], address(1));
		assertEq(userList[1], address(2));
		assertEq(userList[2], address(3));

		assertEq(fundMe.getuserBalance(address(1)), SEND_AMOUNT);
		assertEq(fundMe.getuserBalance(address(2)), SEND_AMOUNT*7);
		assertEq(fundMe.getuserBalance(address(3)), SEND_AMOUNT*3);
	}

	// testing withdraw. Only admin should be able to withdraw.
	function testWithdraw() public {
		address payable _owner = payable(fundMe.getOwner());
		vm.prank(USER1);
		vm.expectRevert("Only owner can withdraw");
		fundMe.withdraw();

		vm.prank(_owner);
		vm.expectRevert("No funds to withdraw");
		fundMe.withdraw();

		// Do some deposits
		_deposit(address(1), SEND_AMOUNT);
		_deposit(address(2), SEND_AMOUNT*2);
		_deposit(address(3), SEND_AMOUNT*5);
		uint256 balBefore = _owner.balance;
		vm.prank(_owner);
		uint256 withdrawnFunds = fundMe.withdraw();
		uint256 balAfter = _owner.balance;
		assertEq(balAfter-balBefore, SEND_AMOUNT*8);
		assertEq(withdrawnFunds, SEND_AMOUNT*8);
	}

	// Internal function for depositing and checking afterwards if the deposited amount is correctly accounted.
	function _deposit(address user, uint256 amount) internal {
		uint256 balBefore = fundMe.getuserBalance(user);
		hoax(user);
		fundMe.fundContract{value: amount}();
		uint256 balAfter = fundMe.getuserBalance(user);
		assertEq(balAfter-balBefore, amount);
	}

}
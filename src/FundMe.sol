//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceGetterOracle} from "./lib/PriceGetterOracle.sol";

/// @title FundMe Contract
/// @notice Users are able to fund the contract with native tokens which can be withdrawn by the owner of the contract
/// @author ElKu
contract FundMe {

	using PriceGetterOracle for AggregatorV3Interface;

	address payable immutable private i_owner;
	mapping(address => uint256) private s_userBal;  //in Native token
	address[] private s_userList;
	uint256 constant public MIN_USD_DEPOSIT = 50 ether;  //with decimals 18.
	AggregatorV3Interface public s_oracle;

	/// @notice Construct the FundMe contract
	/// @param oracle The price oracle for ETH/USD. chainlink contract
    /// @dev Sets owner and price oracle
	constructor(address oracle) {
		i_owner = payable(msg.sender);
		s_oracle = AggregatorV3Interface(oracle);
	}

	/// @notice Any user can send funds to the contract
    /// @dev The msg.value should be greater than `MIN_USD_DEPOSIT`
	function fundContract() payable public {
		require(msg.value > 0, "msg.value cannot be zero");
		uint256 amountInDollars = s_oracle.getPrice() * msg.value / 1 ether;
		require(amountInDollars >= MIN_USD_DEPOSIT, "Not enough deposit amount");
		if(s_userBal[msg.sender] == 0) {
			s_userList.push(msg.sender);
		}
		s_userBal[msg.sender] += msg.value;
	}

	/// @notice Allows owner to withdraw deposited funds.
    /// @dev The deposit information so far is reset.
	function withdraw() external returns(uint256) {
		require(msg.sender == i_owner, "Only owner can withdraw");
		require(address(this).balance > 0, "No funds to withdraw");
		//clear balances
		uint256 len = s_userList.length;
		for(uint256 i; i < len; ) {
			s_userBal[s_userList[i]] = 0;	
			unchecked{
				++i;
			}
		}
		s_userList = new address[](0);
		uint256 availableFunds = address(this).balance;
		(bool success, ) = msg.sender.call{value: availableFunds}("");
		require(success, "Unable to withdraw");
		return availableFunds;
	}
	 
	/// @notice Sending funds directly results in a revert.
	receive() payable external {
		revert();
	}

	/// @notice Sending funds directly results in a revert.
	fallback() payable external {
		revert();
	}

	/***********   View functions.    ***********/

	/// @notice Gets the owner of this contract
    /// @return The owner address
	function getOwner() external view returns(address) {
		return i_owner;
	}

    /// @notice Gets the deposit amount of a particular user
	/// @param user address of the user who's deposit amount you seek
    /// @return User deposit
	function getuserBalance(address user) external view returns(uint256) {
		return s_userBal[user];
	}

	/// @notice Get the list of depositers 
    /// @return List of all depositer's addresses as an array.
	function getUserList() external view returns(address[] memory) {
		return s_userList;
	}

    /// @notice Gets the price oracle address
    /// @return The price oracle address
	function getOracle() external view returns(address) {
		return address(s_oracle);
	}

}
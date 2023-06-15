//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceGetterOracle {
	//get price of eth in usd and convert it into 18 decimals.
	function getPrice(AggregatorV3Interface oracle) internal view returns(uint256) {
		(,int256 price, , , ) = oracle.latestRoundData();
		return uint256(price * 10 ** (18 - 8));
	}

}
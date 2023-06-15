// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

/// Deploy the FundMe contract to the particular chain with the help of the Helper contract.
/// this deployment is used in the test contracts.
contract DeployFundMe is Script {

	HelperConfig helperConfig = new HelperConfig();
	address public oracle = helperConfig.activeNetworkConfig();

	function run() external returns(FundMe) {
		vm.startBroadcast();
		FundMe fundMe =  new FundMe(oracle);
		vm.stopBroadcast();

		return fundMe;
	}

}
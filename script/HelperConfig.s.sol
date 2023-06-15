//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

/// @notice This helper contract helps to deploy to any chain we want, without changing the code in any other files.
/// For more chains to be included here, functions corresponding to those chainid's must be added in this file.
contract HelperConfig is Script {

	uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

	struct NetworkConfig {
		address oracle;
	}
	NetworkConfig public activeNetworkConfig;

	constructor() {
		if(block.chainid == 11155111)
			activeNetworkConfig = getSepoliaConfig();
		else if(block.chainid == 31337)
			activeNetworkConfig = getOrCreateAnvilConfig();
		else if(block.chainid == 1)
			activeNetworkConfig = getMainnetConfig();
		else
			revert();
	}

	function getSepoliaConfig() public pure returns(NetworkConfig memory networkConfig) {
		networkConfig.oracle = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
	}

	// For Anvil local chain, deploy the contract first
	function getOrCreateAnvilConfig() internal returns(NetworkConfig memory networkConfig) {
		if(activeNetworkConfig.oracle != address(0))
			return activeNetworkConfig;

		vm.startBroadcast();
		MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
		vm.stopBroadcast();
		networkConfig.oracle = address(mockV3Aggregator);
	}

	function getMainnetConfig() public pure returns(NetworkConfig memory networkConfig) {
		networkConfig.oracle = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
	}

}
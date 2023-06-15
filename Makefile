-include .env

#deploy and verify on etherscan
deploy-sepolia:
	forge script script/DeployFundMe.s.sol --rpc-url $(ALCHEMY_SEPOLIA_RPC_URL) --broadcast --private-key $(DUMMY_MM_PVT_KEY) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv


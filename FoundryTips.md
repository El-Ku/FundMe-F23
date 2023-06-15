### Environment Variable Names
```
$FOUNDRY_RPC_URL
$FOUNDRY_PVT_KEY
$ALCHEMY_MAINNET_RPC_URL
$ALCHEMY_SEPOLIA_RPC_URL
$INFURA_MAINNET_RPC_URL
$DUMMY_MM_PVT_KEY
$DUMMY_MM_ADDR
$DUMMY_MM_RPC_URL
$ETHERSCAN_API_KEY
```

### Installs the contracts in this link to the lib folder in the current project

```bash
forge install https://github.com/smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit
```

### Test on forked network locally
```bash
forge script ./script/DeployFundMe.s.sol --rpc-url $FOUNDRY_RPC_URL
```

### Run Anvil. Open a new bash shell and run the following command to simulate the deployment on anvil chain.
```bash
forge script ./script/DeployFundMe.s.sol --rpc-url $FOUNDRY_RPC_URL
```

### For deploying the contract on sepolia testnet:
```bash
forge script script/DeployFundMe.s.sol --rpc-url $ALCHEMY_SEPOLIA_RPC_URL --broadcast --private-key $DUMMY_MM_PVT_KEY
```

### For deploying the contract on sepolia testnet and Verify on Etherscan:
```bash
forge script script/DeployFundMe.s.sol --rpc-url $(ALCHEMY_SEPOLIA_RPC_URL) --broadcast --private-key $(DUMMY_MM_PVT_KEY) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
```


# OPYN Vault integration

### Gamma Contracts Deployment

Add following lines in the migrations/2_deploy_contracts.js in GammaProtocal repo, and deploy the contracts
in GammaProtocal repo either locally or on a testnet.

The mock USDC is used as the strike asset and mock WETH is used as underlying asset. This step can be skipped
if deploying on a testnet as respective USDC/WETH contracts can be used.

```
await deployer.deploy(MockERC20USDC, 'USDC', 'USDC', 8, {from: deployerAddress})
const usdc = await MockERC20USDC.deployed()

await deployer.deploy(MockERC20WETH, 'WETH', 'WETH', 8, {from: deployerAddress})
const weth = await MockERC20WETH.deployed()
await weth.mint(deployerAddress, '10000000000')

await whitelist.whitelistCollateral(weth.address)
await whitelist.whitelistCollateral(usdc.address)
whitelist.whitelistProduct(weth.address, usdc.address, usdc.address, true)
whitelist.whitelistProduct(weth.address, usdc.address, weth.address, false)
```

### OpynVault Contract Deployment

Deploy the Opyn Vault smart contract with the following command.
Please make sure that constructor arguments are correct for OpynVault contract.

```shell
npx hardhat run scripts/deploy.ts --network localhost
```

# Console

Following commands can be used to interact with the console, please make sure
that contract addresses are correct. If deployed locally, the contract addresses generated 
from previous step can be used, else if on testnet respective addresses can be used.


```shell
npx hardhat --network localhost console

const weth = await ethers.getContractAt('MockERC20', '0x6eD79Aa1c71FD7BdBC515EfdA3Bd4e26394435cC')
await weth.approve('0x2D8BE6BF0baA74e0A907016679CaE9190e80dD0A', '2000000000')
const vault = await ethers.getContractAt('OpynVault', '0x2D8BE6BF0baA74e0A907016679CaE9190e80dD0A')
await vault.deposit('200000000')
await vault.genOToken()
await vault.createShort()
```

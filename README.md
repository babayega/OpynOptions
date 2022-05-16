# Demo Vault OPYN integration

### Gamma Contracts Deployment

Added following lines in the migrations/2_deploy_contracts.js in GammaProtocal repo

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

### DemoVault Contract Deployment

Deploy the Demo Vault smart contract with the following command.
Please make sure that constructor arguments are correct for DemoVault contract.

```shell
npx hardhat run scripts/deploy.ts --network localhost
```

# Console

Following commands can be used to interact with the console, please make sure
that contract addresses are correct.

```shell
npx hardhat --network localhost console

const weth = await ethers.getContractAt('MockERC20', '0x6eD79Aa1c71FD7BdBC515EfdA3Bd4e26394435cC')
await weth.approve('0x2D8BE6BF0baA74e0A907016679CaE9190e80dD0A', '2000000000')
const demo = await ethers.getContractAt('DemoVault', '0x2D8BE6BF0baA74e0A907016679CaE9190e80dD0A')
await demo.deposit('200000000')
await demo.genOToken()
await demo.createShort()
```

// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const OpynVault = await ethers.getContractFactory("OpynVault");
  const opynVault = await OpynVault.deploy('0x6eD79Aa1c71FD7BdBC515EfdA3Bd4e26394435cC', '0xA94B7f0465E98609391C623d0560C5720a3f2D33', '0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B', '0x0E696947A06550DEf604e82C26fd9E493e576337', '0x67B5656d60a809915323Bf2C40A8bEF15A152e3e');

  await opynVault.deployed();

  console.log("Opyn deployed to:", opynVault.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

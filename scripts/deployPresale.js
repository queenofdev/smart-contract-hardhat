// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const pmxTokenAddress = "0xe62506fa2355904B47230aFfa5F91f09Ce0F4CB2";
  const priceFeedAddress = "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526"
  const presale = await hre.ethers.deployContract("Presale", [
    pmxTokenAddress,
    priceFeedAddress
  ]);

  await presale.waitForDeployment();

  console.log("Deployed Presale Contract")
  const address = await presale.getAddress();
  console.log(address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

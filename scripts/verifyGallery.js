// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {


  const feeDestination = "0xd41C9BafaAac35d479C95196c5d3bf0BB007fDe7";
  const protocolFeePercent = 50;
  const artistFeePercent = 50;
  const uri = "https://degenart-dev.infura-ipfs.io/ipfs/";

  const contractAddress = "0x939E88f797f8029d17cf2D4fd912Ae2E4c306ad0";

  await hre.run(`verify:verify`, {
    address: contractAddress,
    constructorArguments: [
      feeDestination,
      protocolFeePercent,
      artistFeePercent,
      uri
    ]
  });
  console.log("Completed verify");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
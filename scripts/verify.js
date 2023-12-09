const hre = require("hardhat");
async function main() {

  const contractAddress = "0x6A0Cb83Da3A9BfFA3630a877bd65E4Fe9a3629f4";
 
  await hre.run(`verify:verify`, {
    address: contractAddress,
    // constructorArguments: [
    //   "0x79efE29D5429D1A169291136b52d250e9E1bf4Ce"
    //   ]
  });
  console.log("Completed contract verify");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
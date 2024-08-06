const hre = require("hardhat");

async function main() {

  const contract = await hre.ethers.deployContract("Swisstronik", ["Hello Swisstronik!!"]);

  await contract.waitForDeployment();

  console.log(`This is your deployed contract address ${contract.target}`);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

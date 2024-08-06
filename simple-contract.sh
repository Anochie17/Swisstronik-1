#!/bin/bash

print_blue() {
    echo -e "\033[34m$1\033[0m"
}

prompt_for_input() {
    read -p "$1" input
    echo $input
}

print_blue "Installing Hardhat and necessary dependencies..."
echo
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
echo

print_blue "Initializing Hardhat project..."
echo
npx hardhat
echo

print_blue "Removing the default Hardhat configuration file..."
echo
rm hardhat.config.js
echo
read -p "Enter your wallet private key: " PRIVATE_KEY

if [[ $PRIVATE_KEY != 0x* ]]; then
  PRIVATE_KEY="0x$PRIVATE_KEY"
fi

cat <<EOL > hardhat.config.js
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.19",
  networks: {
    swisstronik: {
      url: "https://json-rpc.testnet.swisstronik.com/",
      accounts: ["$PRIVATE_KEY"],
    },
  },
};
EOL

print_blue "Hardhat configuration file has been updated."
echo

rm -f contracts/Lock.sol
sleep 2
cat <<EOL > contracts/Lock.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Swisstronik {
    string private message;

    constructor(string memory _message) payable{
        message = _message;
    }

    function setMessage(string memory _message) public {
        message = _message;
    }

    function getMessage() public view returns(string memory){
        return message;
    }
}
EOL
echo

print_blue "Compiling the contract..."
echo
npx hardhat compile
echo

print_blue "Creating scripts directory and the deployment script..."
echo

mkdir -p scripts

cat <<EOL > scripts/deploy.js
const hre = require("hardhat");

async function main() {

  const contract = await hre.ethers.deployContract("Swisstronik", ["Hello Swisstronik!!"]);

  await contract.waitForDeployment();

  console.log(\`This is your deployed contract address \${contract.target}\`);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
EOL
echo

npx hardhat run scripts/deploy.js --network swisstronik
echo

print_blue "Simple Contract deployment successful, Copy the above contract address and save it somewhere, you need to submit it in Testnet website"
sed -i 's/0x[0-9a-fA-F]*,\?\s*//g' hardhat.config.js
echo
print_blue "PRIVATE_KEY has been removed from hardhat.config.js."
echo
print_blue "Pushing these files to your github Repo link"
git add . && git commit -m "Initial commit" && git push origin main
echo

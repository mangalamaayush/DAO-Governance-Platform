// scripts/deploy.js
const { ethers } = require("hardhat");

async function main() {
  // Deploy the GovToken first
  const GovToken = await ethers.getContractFactory("GovToken");
  const govToken = await GovToken.deploy("Governance Token", "GOV");
  await govToken.deployed();
  console.log(`✅ GovToken deployed at: ${govToken.address}`);

  // Deploy the DAOGovernance contract with GovToken address
  const DAOGovernance = await ethers.getContractFactory("DAOGovernance");
  const daoGovernance = await DAOGovernance.deploy(govToken.address);
  await daoGovernance.deployed();
  console.log(`✅ DAOGovernance deployed at: ${daoGovernance.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });

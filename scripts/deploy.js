const hre = require("hardhat");

async function main() {
    const DAOGovernance = await hre.ethers.getContractFactory("DAOGovernance");
    const dao = await DAOGovernance.deploy();

    await dao.deployed();
    console.log("DAO Governance Contract deployed to:", dao.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

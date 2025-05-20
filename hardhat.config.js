require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

module.exports = {
  solidity: "0.8.18",
  networks: {
    coretestnet2: {
      url: "https://rpc.test2.btcs.network",
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};

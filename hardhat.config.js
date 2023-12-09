require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  // defaultNetwork: "polygonMumbai",
  // defaultNetwork: "polygonMumbai",
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },

    // live net
    mainnet: {
      // ethereum
      url: process.env.ETHEREUM_MAINNET_RPC,
      chainId: 1,
      accounts: [process.env.PRIVATE_KEY],
    },
    bsc: {
      // bsc
      url: process.env.BSC_RPC,
      chainId: 56,
      accounts: [process.env.PRIVATE_KEY],
    },
    avalanche: {
      // avalanche
      url: process.env.AVAX_RPC,
      chainId: 43114,
      accounts: [process.env.PRIVATE_KEY],
    },
    polygon: {
      // polygon
      url: process.env.POLYGON_RPC,
      chainId: 137,
      accounts: [process.env.PRIVATE_KEY],
    },
    arbitrumOne: {
      // arbitrum
      url: process.env.ARBITRUM_RPC,
      chainId: 42161,
      accounts: [process.env.PRIVATE_KEY],
    },
    optimisticEthereum: {
      // optimism
      url: process.env.OPTIMISM_RPC,
      chainId: 10,
      accounts: [process.env.PRIVATE_KEY],
    },
    opera: {
      // fantom
      url: process.env.FANTOM_RPC,
      chainId: 250,
      accounts: [process.env.PRIVATE_KEY],
    },
    //

    // test net
    goerli: {
      url: process.env.GOERLI_TESTNET_RPC,
      chainId: 5,
      accounts: [process.env.PRIVATE_KEY],
    },

    // test pulse net
    pulse: {
      url: process.env.PULSE_TESTNET_RPC,
      chainId: 943,
      accounts: [process.env.PRIVATE_KEY],
    },

    bscTestnet: {
      // bsc testnet
      url: process.env.BSC_TESTNET_RPC,
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [process.env.PRIVATE_KEY],
    },

    pulseTestnet: {
      url: "https://pulsechain-testnet.publicnode.com",
      chainId: 943,
      gasPrice: 20000000000,
      accounts:[process.env.PRIVATE_KEY],
    },

    avalancheFujiTestnet: {
      // fuji
      url: process.env.AVAX_TESTNET_RPC,
      chainId: 43113,
      accounts: [process.env.PRIVATE_KEY],
    },
    polygonMumbai: {
      // mumbai
      url: process.env.MUMBAI_TESTNET_RPC,
      chainId: 80001,
      gasPrice: 20000000000,
      accounts: [process.env.PRIVATE_KEY],
    },
    arbitrumGoerli: {
      // arbitrum goerli
      url: process.env.ARBITRUM_GOERLI_TESTNET_RPC,
      chainId: 421613,
      accounts: [process.env.PRIVATE_KEY],
    },
    optimisticGoerli: {
      // optimism goerli
      url: process.env.OPTIMISIM_GOERLI_TESTNET_RPC,
      chainId: 420,
      accounts: [process.env.PRIVATE_KEY],
    },
    ftmTestnet: {
      // fantom testnet
      url: process.env.FANTOM_TESTNET_RPC,
      chainId: 4002,
      accounts: [process.env.PRIVATE_KEY],
    },
    //
  },
  sourcify: {
    // Disabled by default
    // Doesn't need an API key
    enabled: true
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/

    apiKey: {
      mainnet: process.env.ETHEREUM_API_KEY,
      goerli: process.env.ETHEREUM_API_KEY,
      bsc: process.env.BSC_API_KEY,
      bscTestnet: process.env.BSC_API_KEY,
      ftmTestnet: process.env.FANTOM_API_KEY,
      polygon: process.env.POLYGON_API_KEY,
      polygonMumbai: process.env.POLYGON_API_KEY,
    },
    customChains: [
      {
        network: "pulseTestnet",
        chainId: 943,
        urls: {
          apiURL: "https://scan.v4.testnet.pulsechain.com/api",
          browserURL: "https://scan.v4.testnet.pulsechain.com/"
        }
      }
    ],
    
  },
  mocha: {
    timeout: 40000000000000,
  },
};

const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    development: {
      provider: () => new HDWalletProvider({
        privateKeys: [
          '8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63',
          'c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3',
          'ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f'
        ],
        providerOrUrl: 'http://127.0.0.1:8545', // Your Besu network URL
        chainId: 1337 // Your network's chain ID
      }),
      network_id: '*',
      gas: 8000000, // Adjust this value if necessary
      gasPrice: 20000000000
    }
  },

  compilers: {
    solc: {
      version: '0.8.0', // Specify your Solidity version here
    }
  }
};


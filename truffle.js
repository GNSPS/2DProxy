/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a 
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() { 
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>') 
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    // ganache: {
    //   host: "localhost",
    //   port: 7545,
    //   network_id: "*" // Match any network id
    // },
  },
  compilers: {
    external: {
      command: "truffle compile --compiler=solc --contracts_build_directory=external",
      targets: [{
        path: "contracts/2dproxy/*.sol",
        command: "./2dproxy_bin/truffle/2dproxy_extractor_truffle_ctor.sh",
        stdin: false
      },
      {
        path: "contracts/2dproxy/*.sol",
        command: "./2dproxy_bin/truffle/2dproxy_extractor_truffle_runtime.sh",
        stdin: false
      }]
    }
  }
};
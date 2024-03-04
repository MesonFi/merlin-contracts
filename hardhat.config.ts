import '@nomiclabs/hardhat-ethers'

import { task } from 'hardhat/config'

import config from './config.json'

task('deploy_lock', 'Deploy ERC20LockContract')
  .setAction(async () => {
    const deploy = require('./scripts/deploy_lock')
    await deploy()
  })

task('deploy_erc20', 'Deploy ERC20WithConvertible contract')
  .setAction(async () => {
    const deploy = require('./scripts/deploy_erc20')
    await deploy()
  })

task('deploy_timelock', 'Deploy TimeLockContract')
  .setAction(async () => {
    const deploy = require('./scripts/deploy_timelock')
    await deploy()
  })

task('deploy_timelock_tron', 'Deploy TimeLockContract on Tron')
  .setAction(async () => {
    const deploy = require('./scripts/deploy_timelock_tron')
    await deploy()
  })

export default {
  solidity: {
    version: config.compilers.solc,
    settings: {
      optimizer: config.compilers.optimizer,
      evmVersion: config.compilers.evmVersion,
      viaIR: true,
      metadata: {
        // do not include the metadata hash, since this is machine dependent
        // and we want all generated code to be deterministic
        // https://docs.soliditylang.org/en/v0.7.6/metadata.html
        bytecodeHash: 'none',
      },
    },
  },
  defaultNetwork: 'manta',
  networks: {
    mainnet: {
      url: "https://rpc.ankr.com/eth",
    },
    arbitrum: {
      url: "https://1rpc.io/arb",
    },
    manta: {
      url: "https://pacific-rpc.manta.network/http",
    },
    goerli: {
      url: "https://rpc.ankr.com/eth_goerli",
    },
    sepolia: {
      url: "https://rpc.sepolia.org",
    },
    arb_sepolia: {
      url: "https://sepolia-rollup.arbitrum.io/rpc",
    },
  },
  typechain: {
    outDir: 'packages/contract-types/types',
  }
}

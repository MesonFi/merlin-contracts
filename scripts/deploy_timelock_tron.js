const TronWeb = require('tronweb')
const { ethers } = require('hardhat')

require('dotenv').config()

const {
  TRON_RPC,
  TRON_BENEFICIARY,
  PRIVATE_KEY,
} = process.env

module.exports = async function deploy_timelock_tron() {
  await hre.run('compile')

  const beneficiary = TronWeb.address.fromHex(TRON_BENEFICIARY)
  console.log('beneficiary:', beneficiary)

  const releaseTime = new Date('2024-04-20T00:00:00.000Z').valueOf() / 1000

  const factory = await ethers.getContractFactory('TimeLockContract')
  const abi = JSON.parse(factory.interface.format('json'))
  const constructor = abi.find(({ type }) => type === 'constructor')
  if (constructor) {
    constructor.stateMutability = constructor.payable ? 'payable' : 'nonpayable'
  }

  const tronWeb = new TronWeb({ fullHost: TRON_RPC, privateKey: PRIVATE_KEY.substring(2) })
  const deployed = await tronWeb.contract().new({
    abi,
    bytecode: factory.bytecode,
    feeLimit: 5000_000000,
    callValue: 0,
    parameters: [beneficiary, releaseTime]
  })

  const contractAddress = TronWeb.address.fromHex(deployed.address)
  console.log(`TimeLockContract deployed on Tron to:`, contractAddress)
}

const { ethers } = require('hardhat')

require('dotenv').config()

const {
  PRIVATE_KEY,
  BENEFICIARY,
} = process.env

module.exports = async function deploy_timelock() {
  await hre.run('compile')

  const wallet = new ethers.Wallet(PRIVATE_KEY, ethers.provider)

  const beneficiary = BENEFICIARY || wallet.address
  console.log('beneficiary:', beneficiary)
  const releaseTime = new Date('2024-04-20T00:00:00.000Z').valueOf() / 1000

  const factory = await ethers.getContractFactory('TimeLockContract', wallet)
  const instance = await factory.deploy(beneficiary, releaseTime)
  await instance.deployed()

  console.log(`TimeLockContract deployed to:`, instance.address)
}

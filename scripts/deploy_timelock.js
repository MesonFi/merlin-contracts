const { ethers } = require('hardhat')

require('dotenv').config()

const {
  PRIVATE_KEY,
} = process.env

module.exports = async function deploy_timelock() {
  await hre.run('compile')

  const wallet = new ethers.Wallet(PRIVATE_KEY, ethers.provider)

  const releaseTime = 0 // Math.floor(new Date('YYYY-MM-DD').valueOf() / 1000)

  const factory = await ethers.getContractFactory('TimeLockContract', wallet)
  const instance = await factory.deploy(releaseTime)
  await instance.deployed()

  console.log(`TimeLockContract deployed to:`, instance.address)
}

const { ethers } = require('hardhat')

require('dotenv').config()

const {
  PRIVATE_KEY,
  LOCK_ADMIN,
  LOCK_OPERATOR,
} = process.env

module.exports = async function deploy_lock() {
  await hre.run('compile')

  const wallet = new ethers.Wallet(PRIVATE_KEY, ethers.provider)
  console.log('Signer:', wallet.address)

  const admin = ethers.utils.getAddress(LOCK_ADMIN)
  const operator = ethers.utils.getAddress(LOCK_OPERATOR)

  console.log('Admin:', admin)
  console.log('Operator:', operator)

  console.log('Deploying ERC20LockContract implementation...')
  const ERC20LockContract = await ethers.getContractFactory('ERC20LockContract', wallet)
  const impl = await ERC20LockContract.deploy()
  await impl.deployed()
  console.log(`Implementation deployed at: ${impl.address}`)

  console.log('Deploying Proxy...')
  const data = impl.interface.encodeFunctionData('initialize', [admin, operator])
  const ERC1967Proxy = await ethers.getContractFactory('ERC1967Proxy', wallet)
  const deployed = await ERC1967Proxy.deploy(impl.address, data)
  await deployed.deployed()
  console.log(`ERC20LockContract deployed at: ${deployed.address}`)
}

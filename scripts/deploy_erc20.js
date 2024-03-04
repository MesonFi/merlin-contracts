const { ethers } = require('hardhat')

require('dotenv').config()

const {
  PRIVATE_KEY,
  MERLIN_ERC20_ADMIN,
  MERLIN_ERC20_MINTER,
  TOKEN_NAME = 'ERC20 Token',
  TOKEN_SYMBOL = 'TOKEN',
  TOKEN_DECIMALS = 18,
} = process.env

module.exports = async function deploy_erc20() {
  await hre.run('compile')

  const wallet = new ethers.Wallet(PRIVATE_KEY, ethers.provider)
  console.log('Signer:', wallet.address)

  const admin = ethers.utils.getAddress(MERLIN_ERC20_ADMIN)
  const minter = ethers.utils.getAddress(MERLIN_ERC20_MINTER)

  console.log('Admin:', admin)
  console.log('Minter:', minter)

  console.log('Deploying ERC20WithConvertible implementation...')
  const ERC20WithConvertible = await ethers.getContractFactory('ERC20WithConvertible', wallet)
  const impl = await ERC20WithConvertible.deploy()
  await impl.deployed()
  console.log(`Implementation deployed at: ${impl.address}`)

  console.log('Deploying Proxy...')
  const data = impl.interface.encodeFunctionData('initialize', [admin, TOKEN_NAME, TOKEN_SYMBOL, Number(TOKEN_DECIMALS), minter])
  const ERC1967Proxy = await ethers.getContractFactory('ERC1967Proxy', wallet)
  const deployed = await ERC1967Proxy.deploy(impl.address, data)
  await deployed.deployed()
  console.log(`ERC20WithConvertible deployed at: ${deployed.address}`)

  const ConvertibleERC20 = await ethers.getContractFactory('ConvertibleERC20', wallet)
  const inputData = ConvertibleERC20.interface.encodeDeploy([admin, `Convertible ${TOKEN_NAME}`, `m${TOKEN_SYMBOL}`, Number(TOKEN_DECIMALS), minter, deployed.address])
  console.log(`ConvertibleERC20 input data: ${inputData}`)
}

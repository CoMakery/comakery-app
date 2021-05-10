const EthereumBlockchain = require('../lib/blockchains/EthereumBlockchain').EthereumBlockchain
const BigNumber = require('bignumber.js')

// TODO: For now it doing real request to blockchain, need to mock it somehow
describe("EthereumBlockchain check for token balance", () => {
  test('return balance as a BigNumber object', async () => {
    const ethBlockchain = new EthereumBlockchain({
      infuraProjectId: "39f6ad316c5a4b87a0f90956333c3666",
      blockchainNetwork: 'ethereum_ropsten',
      ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
    })

    const balance = await ethBlockchain.getTokenBalance("0x2aA78Db0BEff941883C33EA150ed86eaDE09A377")
    expect(balance).toEqual(new BigNumber("52"))
  })

  test('return zero for unknown contract', async () => {
    const ethBlockchain = new EthereumBlockchain({
      infuraProjectId: "39f6ad316c5a4b87a0f90956333c3666",
      blockchainNetwork: 'ethereum_ropsten',
      ethereumContractAddress: "0xB5e3062f536cE503B27CB366529613aa3bE0408e"
    })

    const balance = await ethBlockchain.getTokenBalance("0x2aA78Db0BEff941883C33EA150ed86eaDE09A377")
    expect(balance).toEqual(new BigNumber("0"))
  })
});

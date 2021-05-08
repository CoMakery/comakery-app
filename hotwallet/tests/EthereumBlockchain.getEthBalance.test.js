const EthereumBlockchain = require('../lib/blockchains/EthereumBlockchain').EthereumBlockchain
const BigNumber = require('bignumber.js')

describe("EthereumBlockchain check for eth balance", () => {
  test('return balance as a BigNumber object', async () => {
    const ethBlockchain = new EthereumBlockchain({
      infuraProjectId: "39f6ad316c5a4b87a0f90956333c3666",
      blockchainNetwork: 'ethereum_ropsten'
    })

    jest.spyOn(ethBlockchain, "connect").mockImplementation(() => { return true });
    jest.spyOn(ethBlockchain.chain, "fetchBalance").mockImplementation(() => { return { balance: "99.5" } });

    const balance = await ethBlockchain.getEthBalance("0x2aA78Db0BEff941883C33EA150ed86eaDE09A377")
    expect(balance).toEqual(new BigNumber("99.5"))
  })

  test('return zero of something went wrong', async () => {
    const ethBlockchain = new EthereumBlockchain({
      infuraProjectId: "39f6ad316c5a4b87a0f90956333c3666",
      blockchainNetwork: 'ethereum_ropsten'
    })

    jest.spyOn(ethBlockchain, "connect").mockImplementation(() => { return true });
    jest.spyOn(ethBlockchain.chain, "fetchBalance").mockImplementation(() => { return { something: "wrong" } });

    const balance = await ethBlockchain.getEthBalance("0x2aA78Db0BEff941883C33EA150ed86eaDE09A377")
    expect(balance).toEqual(new BigNumber(0))
  })
});

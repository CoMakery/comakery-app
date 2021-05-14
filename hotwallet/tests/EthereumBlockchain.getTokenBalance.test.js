
const EthereumBlockchain = require('../lib/blockchains/EthereumBlockchain').EthereumBlockchain
const BigNumber = require('bignumber.js')

describe("EthereumBlockchain check for token balance", () => {
  test('return balance as a BigNumber object', async () => {
    const ethBlockchain = new EthereumBlockchain({
      infuraProjectId: "infura_project_id",
      blockchainNetwork: 'ethereum_ropsten',
      ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
    })

    const tokenContractMocked = jest.fn().mockReturnValue({
      methods: {
        balanceOf: () => { return { call: () => "52"}},
        decimals: () => { return { call: () => "0"}},
      }
    })
    jest.spyOn(ethBlockchain, "connect").mockReturnValue(true)
    jest.spyOn(ethBlockchain, "tokenContract").mockImplementation(tokenContractMocked)

    const balance = await ethBlockchain.getTokenBalance("0x2aA78Db0BEff941883C33EA150ed86eaDE09A377")
    expect(balance).toEqual(new BigNumber("52"))
    expect(tokenContractMocked).toHaveBeenCalledWith("0x1d1592c28fff3d3e71b1d29e31147846026a0a37")
  })

  test('return zero for unknown contract', async () => {
    const ethBlockchain = new EthereumBlockchain({
      infuraProjectId: "infura_project_id",
      blockchainNetwork: 'ethereum_ropsten',
      ethereumContractAddress: "0xB5e3062f536cE503B27CB366529613aa3bE0408e"
    })

    const tokenContractMocked = jest.fn().mockReturnValue({
      methods: {
        balanceOf: () => { return { call: () => "0"}},
        decimals: () => { return { call: () => "0"}},
      }
    })
    jest.spyOn(ethBlockchain, "connect").mockReturnValue(true)
    jest.spyOn(ethBlockchain, "tokenContract").mockImplementation(tokenContractMocked)

    const balance = await ethBlockchain.getTokenBalance("0x2aA78Db0BEff941883C33EA150ed86eaDE09A377")
    expect(balance).toEqual(new BigNumber("0"))
    expect(tokenContractMocked).toHaveBeenCalledWith("0xB5e3062f536cE503B27CB366529613aa3bE0408e")

  })

  test('get ethereumApprovalContractAddress balance for Lockup contract', async () => {
    const ethBlockchain = new EthereumBlockchain({
      infuraProjectId: "infura_project_id",
      blockchainNetwork: 'ethereum_rinkeby',
      ethereumTokenType: "token_release_schedule",
      ethereumContractAddress: "0x9608848fa0063063d2bb401e8b5effcb8152ec65",
      ethereumApprovalContractAddress: "0x68ac9A329c688AfBf1FC2e5d3e8Cb6E88989E2cC",
    })

    const tokenContractMocked = jest.fn().mockReturnValue({
      methods: {
        balanceOf: () => { return { call: () => "99"}},
        decimals: () => { return { call: () => "2"}},
      }
    })
    jest.spyOn(ethBlockchain, "connect").mockReturnValue(true)
    jest.spyOn(ethBlockchain, "tokenContract").mockImplementation(tokenContractMocked)

    const balance = await ethBlockchain.getTokenBalance("0x2aA78Db0BEff941883C33EA150ed86eaDE09A377")
    expect(balance).toEqual(new BigNumber("0.99"))
    expect(tokenContractMocked).toHaveBeenCalledWith("0x68ac9A329c688AfBf1FC2e5d3e8Cb6E88989E2cC")
  })
});

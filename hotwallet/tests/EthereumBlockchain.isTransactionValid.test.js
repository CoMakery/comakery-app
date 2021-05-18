
const EthereumBlockchain = require('../lib/blockchains/EthereumBlockchain').EthereumBlockchain
const BigNumber = require('bignumber.js')

describe("EthereumBlockchain.isTransactionValid", () => {
  const hwAddress = '0x15b4eda54e7aa56e4ca4fe6c19f7bf9d82eca2fc'
  const ethBlockchain = new EthereumBlockchain({
    infuraProjectId: "infura_project_id",
    blockchainNetwork: 'ethereum_ropsten',
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  })

  const testBlockchainTransaction = {
    id: 2505,
    blockchainTransactableId: null,
    blockchainTransactableType: null,
    destination: '0x2aA78Db0BEff941883C33EA150ed86eaDE09A377',
    source: '0x15b4eda54e7aa56e4ca4fe6c19f7bf9d82eca2fc',
    amount: 5,
    nonce: null,
    contractAddress: '0xE322488096C36edccE397D179E7b1217353884BB',
    network: 'ethereum_rinkeby',
    txHash: null,
    txRaw: '{"from":"0x15b4eda54e7aa56e4ca4fe6c19f7bf9d82eca2fc","to":"0xE322488096C36edccE397D179E7b1217353884BB","value":"0x0","contract":{"abi":[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}],"method":"transfer","parameters":["0x2aA78Db0BEff941883C33EA150ed86eaDE09A377","5"]}}',
    status: 'created',
    statusMessage: null,
    createdAt: '2021-05-18T08:33:01.217Z',
    updatedAt: '2021-05-18T08:33:01.217Z',
    syncedAt: null,
    blockchainTransactables: [
      {
        id: null,
        blockchainTransactableType: 'Award',
        blockchainTransactableId: 110
      }
    ]
  }

  test('for valid blockchainTransaction', async () => {
    const bt = {...testBlockchainTransaction}
    jest.spyOn(ethBlockchain, "getTokenBalance").mockReturnValueOnce(new BigNumber(10))

    const validResults = await ethBlockchain.isTransactionValid(bt, hwAddress)
    expect(validResults.valid).toBe(true)
    expect(validResults.markAs).toBe(undefined)
    expect(validResults.error).toBe(undefined)
  })

  test('for incorrect txRaw', async () => {
    const bt = {...testBlockchainTransaction}
    bt["txRaw"] = null

    const validResults = await ethBlockchain.isTransactionValid(bt, hwAddress)
    expect(validResults.valid).toBe(false)
    expect(validResults.markAs).toBe(undefined)
    expect(validResults.error).toBe(undefined)
  })

  test('for not enough tokens', async () => {
    const bt = {...testBlockchainTransaction}

    jest.spyOn(ethBlockchain, "getTokenBalance").mockReturnValueOnce(new BigNumber(4))

    const validResults = await ethBlockchain.isTransactionValid(bt, hwAddress)
    expect(validResults.valid).toBe(false)
    expect(validResults.markAs).toBe("cancelled")
    expect(validResults.error).toEqual("The Hot Wallet has insufficient tokens. Please top up the 0x15b4eda54e7aa56e4ca4fe6c19f7bf9d82eca2fc")
  })

  test('for unknown error', async () => {
    const bt = {...testBlockchainTransaction}
    jest.spyOn(ethBlockchain, "getTokenBalance").mockReturnValueOnce({})

    const validResults = await ethBlockchain.isTransactionValid(bt, hwAddress)
    expect(validResults.valid).toBe(false)
    expect(validResults.markAs).toBe("failed")
    expect(validResults.error).toEqual("Unknown error: TypeError: tokenBalance.isLessThan is not a function")
  })
});

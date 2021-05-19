ERC20ABI = require("./erc20abi").ERC20ABI

const txRaw = {
  from: "0x15b4eda54e7aa56e4ca4fe6c19f7bf9d82eca2fc",
  to: "0xE322488096C36edccE397D179E7b1217353884BB",
  value: "0x0",
  contract:
  {
    abi: ERC20ABI,
    method: "transfer",
    parameters: ["0x2aA78Db0BEff941883C33EA150ed86eaDE09A377", "5"]
  }
}

const blockchainTransaction = {
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
  txRaw: JSON.stringify(txRaw),
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

module.exports = { blockchainTransaction }

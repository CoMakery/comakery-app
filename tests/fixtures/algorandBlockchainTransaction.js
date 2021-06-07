ERC20ABI = require("./erc20abi").ERC20ABI


const txRaw = {
  type: "appl",
  from: "5CNLUUIIKC52MNNEUAJD6QZDVBQJWQD2M5N2MHDQ6M3Y372WWUJCYQXUUU",
  appIndex: 13997710,
  appAccounts: ["U7A22RJ53S2G2MOW5JZLPFDLT4IKABMPBUQW2BHW5HSAYUP76CQKCPB7MQ"],
  appArgs: ["0x7472616e73666572", "0x05"],
  appOnComplete: 0
}

const blockchainTransaction = {
  id: 999,
  blockchainTransactableId: null,
  blockchainTransactableType: null,
  destination: 'U7A22RJ53S2G2MOW5JZLPFDLT4IKABMPBUQW2BHW5HSAYUP76CQKCPB7MQ',
  source: '5CNLUUIIKC52MNNEUAJD6QZDVBQJWQD2M5N2MHDQ6M3Y372WWUJCYQXUUU',
  amount: 5,
  nonce: null,
  contractAddress: '13997710',
  network: 'algorand_test',
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

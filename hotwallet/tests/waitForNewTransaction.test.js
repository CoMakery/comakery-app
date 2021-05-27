const axios = require("axios")
const redis = require("redis")
const hwUtils = require("../lib/hotwalletUtils")
jest.mock("axios")

describe("For Ethereum blockchain", () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: null,
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    blockchainNetwork: "ethereum_ropsten"
  }
  const redisClient = redis.createClient()
  const hwRedis = new hwUtils.HotWalletRedis(envs, redisClient)
  const wallet = new hwUtils.HotWallet("ethereum_ropsten", "0x15b4eda54e7aa56e4ca4fe6c19f7bf9d82eca2fc", {})

  beforeEach(() => {
    jest.spyOn(hwRedis, "hotWallet").mockReturnValueOnce(wallet)
  })

  afterEach(() => {
    jest.resetAllMocks()
  })

  afterAll(() => {
    redisClient.quit()
  });

  test("with zero ETH balance", async () => {
    jest.spyOn(hwUtils.Blockchain.prototype, "enoughCoinBalanceToSendTransaction").mockReturnValueOnce(false)

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toEqual({"blockchainTransaction": {}, "status": "failed_before_getting_tx", "transaction": {}})
  })

  test("with zero token balance", async () => {
    jest.spyOn(hwUtils.Blockchain.prototype, "enoughCoinBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(wallet, "isReadyToSendTx").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.Blockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(false)

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toEqual({"blockchainTransaction": {}, "status": "failed_before_getting_tx", "transaction": {}})
  })

  test("API returns empty response", async () => {
    jest.spyOn(hwUtils.Blockchain.prototype, "enoughCoinBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(wallet, "isReadyToSendTx").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.Blockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce({ status: 204, data: null });

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toEqual({"blockchainTransaction": {"data": null, "status": 204}, "status": "validation_failed", "transaction": {}})
  })

  test("API returns a blockchain transaction", async () => {
    jest.spyOn(hwUtils.Blockchain.prototype, "enoughCoinBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(wallet, "isReadyToSendTx").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.Blockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.Blockchain.prototype, "isTransactionValid").mockReturnValueOnce({ valid: true })
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce({ txHash: "TXHASH" })
    jest.spyOn(hwUtils.Blockchain.prototype, "sendTransaction").mockReturnValueOnce({ transactionId: "TXHASH" })
    axios.put.mockImplementation(() => Promise.resolve({ status: 200, data: { id: 99, network: "ethereum_ropsten", txHash: "TXHASH" } }))

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toEqual({"blockchainTransaction": {"txHash": "TXHASH"}, "status": "successfull", "transaction": {"transactionId": "TXHASH"}})
  })

  test("with validation error", async () => {
    jest.spyOn(hwUtils.Blockchain.prototype, "enoughCoinBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(wallet, "isReadyToSendTx").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.Blockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.Blockchain.prototype, "isTransactionValid").mockReturnValueOnce({ valid: false, error: "Some error" })
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce({})

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)
    expect(res).toEqual({"blockchainTransaction": {}, "status": "validation_failed", "transaction": {}})
  })

  test("transaction sending was failed", async () => {
    jest.spyOn(hwUtils.Blockchain.prototype, "enoughCoinBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(wallet, "isReadyToSendTx").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.Blockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.Blockchain.prototype, "isTransactionValid").mockReturnValueOnce({ valid: true })
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce({ txHash: "TXHASH" })
    jest.spyOn(hwUtils.Blockchain.prototype, "sendTransaction").mockReturnValueOnce({ valid: false, markAs: "failed", error: "some error" })

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)
    expect(res).toEqual({
      "blockchainTransaction": { "txHash": "TXHASH" },
      "status": "cancelled_transaction",
      "transaction": { "error": "some error", "markAs": "failed", "valid": false }
    })
  })

  test("validation mark the transaction as failed", async () => {
    jest.spyOn(hwUtils.Blockchain.prototype, "enoughCoinBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(wallet, "isReadyToSendTx").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.Blockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)
    const transaction = { txHash: "TXHASH" }
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce(transaction);
    jest.spyOn(hwUtils.ComakeryApi.prototype, "cancelTransaction").mockReturnValueOnce({ status: 200, data: transaction })
    jest.spyOn(hwUtils.Blockchain.prototype, "isTransactionValid").mockReturnValueOnce({ valid: false, error: "Some error", markAs: "failed" })

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toEqual({"blockchainTransaction": {"txHash": "TXHASH"}, "status": "validation_failed", "transaction": {}})
  })

  test("validation mark the transaction as cancelled", async () => {
    jest.spyOn(hwUtils.Blockchain.prototype, "enoughCoinBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(wallet, "isReadyToSendTx").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.Blockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)
    const transaction = { txHash: "TXHASH" }
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce(transaction);
    jest.spyOn(hwUtils.ComakeryApi.prototype, "cancelTransaction").mockReturnValueOnce({ status: 200, data: transaction })
    jest.spyOn(hwUtils.Blockchain.prototype, "isTransactionValid").mockReturnValueOnce({ valid: false, error: "Some error", markAs: "cancelled" })

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toEqual({"blockchainTransaction": {"txHash": "TXHASH"}, "status": "validation_failed", "transaction": {}})
  })
});


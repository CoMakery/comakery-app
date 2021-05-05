const axios = require("axios")
const redis = require("redis")
const hwUtils = require("../lib/hotwalletUtils")
const envs = {
  projectId: "1",
  projectApiKey: "project_api_key",
  comakeryServerUrl: null,
  purestakeApi: "purestake_api_key",
  redisUrl: "redis://localhost:6379/0",
  emptyQueueDelay: 30
}
const wallet = new hwUtils.HotWallet("algorand_test", "YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4", "mnemonic phrase")
jest.mock("axios")

describe.skip("Wait for new transaction suite", async () => {
  const redisClient = redis.createClient()
  const hwRedis = new hwUtils.HotWalletRedis(envs, redisClient)

  beforeEach(async () => {
    await hwRedis.saveNewHotWallet(wallet)
  })

  afterEach(() => {
    jest.resetAllMocks()
  })

  afterAll(() => {
    redisClient.quit()
  });

  test("not enough ALGOs to send transactions", async () => {
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValueOnce(false)

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toBe(false)
  })

  test("hot wallet has zero tokens", async () => {
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(false)

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toBe(false)
  })

  test("API returns empty response", async () => {
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce({ status: 204, data: null });
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isTransactionValid").mockReturnValueOnce({ valid: false })

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toBe(false)
  })

  test("API returns a blockchain transaction", async () => {
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce({ txHash: "TXHASH" });
    axios.put.mockImplementation(() => Promise.resolve({ status: 200, data: { id: 99, network: "algorand_test", txHash: "TXHASH" } }))
    jest.spyOn(hwUtils, "signAndSendTx").mockImplementation(() => { return { transactionId: "TXHASH" } });
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isTransactionValid").mockReturnValueOnce({ valid: true })


    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toBe(true)
  })

  test("API returns failed response", async () => {
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce({});
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isTransactionValid").mockReturnValueOnce({ valid: false, error: "Some error" })

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)
    expect(res).toBe(false)
  })

  test("signAndSendTx returns empty object", async () => {
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce({ txHash: "TXHASH" });
    jest.spyOn(hwUtils, "signAndSendTx").mockReturnValueOnce({});
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isTransactionValid").mockReturnValueOnce({ valid: false, error: "Some error" })

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)
    expect(res).toBe(false)
  })

  test("validation mark the transaction as failed", async () => {
    const transaction = { txHash: "TXHASH" }
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce(transaction);
    jest.spyOn(hwUtils.ComakeryApi.prototype, "cancelTransaction").mockReturnValueOnce({ status: 200, data: transaction })
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isTransactionValid").mockReturnValueOnce({ valid: false, error: "Some error", markAs: "failed" })
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toBe(false)
  })

  test("validation mark the transaction as failed", async () => {
    const transaction = { txHash: "TXHASH" }
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce(transaction);
    jest.spyOn(hwUtils.ComakeryApi.prototype, "cancelTransaction").mockReturnValueOnce({ status: 200, data: transaction })
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isTransactionValid").mockReturnValueOnce({ valid: false, error: "Some error", markAs: "cancelled" })
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toBe(false)
  })

  test("validation does not mark the transaction as failed", async () => {
    const transaction = { txHash: "TXHASH" }
    jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValueOnce({ status: 200, data: transaction });
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isTransactionValid").mockReturnValueOnce({ valid: false, error: "Some error" })
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValueOnce(true)
    jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValueOnce(true)

    const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

    expect(res).toBe(false)
  })
});


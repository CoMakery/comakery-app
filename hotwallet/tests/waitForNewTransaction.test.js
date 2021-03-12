const axios = require("axios")
const redis = require("redis")
const hwUtils = require("../lib/hotwalletUtils")
const envs = {
  projectId: "1",
  projectApiKey: "project_api_key",
  comakeryServerUrl: null,
  purestakeApi: "purestake_api_key",
  redisUrl: "redis://localhost:6379/0",
  checkForNewTransactionsDelay: 30
}
const wallet = new hwUtils.HotWallet("YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4", "mnemonic phrase")

jest.mock("axios")

const redisClient = redis.createClient()
const hwRedis = new hwUtils.HotWalletRedis(envs, redisClient)

beforeEach(async () => {
  await hwRedis.saveNewHotWallet(wallet)
})

afterAll(() => {
  redisClient.quit()
  jest.restoreAllMocks()
});

test("not enough ALGOs to send transactions", async () => {
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValue(false)

  const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

  expect(res).toBe(false)
})

test("hot wallet has zero tokens", async () => {
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValue(true)
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValue(false)

  const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

  expect(res).toBe(false)
})

test("API returns empty response", async () => {
  expect.assertions(1);
  axios.post.mockImplementation(() => Promise.resolve({ status: 204, data: null }))
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValue(true)
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValue(true)
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isTransactionValid").mockReturnValue({ valid: false, error: "Some error"})

  const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

  expect(res).toBe(false)
})

test("API returns a blockchain transaction", async () => {
  expect.assertions(1);
  axios.post.mockImplementation(() => Promise.resolve({ status: 201, data: { id: 99, network: "algorand_test" } }))
  axios.put.mockImplementation(() => Promise.resolve({ status: 200, data: { id: 99, network: "algorand_test", txHash: "TXHASH" } }))
  jest.spyOn(hwUtils, "signAndSendTx").mockImplementation(() => { return { transactionId: "TXHASH" } });
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValue(true)
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValue(true)
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isTransactionValid").mockReturnValue({valid: true})


  const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

  expect(res).toBe(true)
})

test("API returns failed response", async () => {
  jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValue({});
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValue(true)
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValue(true)
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isTransactionValid").mockReturnValue({ valid: false, error: "Some error"})

  const res = await hwUtils.waitForNewTransaction(envs, hwRedis)
  expect(res).toBe(false)
})

test("signAndSendTx returns empty object", async () => {
  jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValue({ txHash: "TXHASH" });
  jest.spyOn(hwUtils, "signAndSendTx").mockReturnValue({});
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughAlgoBalanceToSendTransaction").mockReturnValue(true)
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "positiveTokenBalance").mockReturnValue(true)
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isTransactionValid").mockReturnValue({ valid: false, error: "Some error"})

  const res = await hwUtils.waitForNewTransaction(envs, hwRedis)
  expect(res).toBe(false)
})

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

test("API returns empty response", async () => {
  expect.assertions(1);
  axios.post.mockImplementation(() => Promise.resolve({ status: 204, data: null }))
  const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

  expect(res).toBe(false)
})

test("API returns a blockchain transaction", async () => {
  expect.assertions(1);
  axios.post.mockImplementation(() => Promise.resolve({ status: 201, data: { id: 99, network: "algorand_test" } }))
  axios.put.mockImplementation(() => Promise.resolve({ status: 200, data: { id: 99, network: "algorand_test", txHash: "TXHASH" } }))
  jest.spyOn(hwUtils, "singAndSendTx").mockImplementation(() =>{return { transactionId: "TXHASH" }});
  const res = await hwUtils.waitForNewTransaction(envs, hwRedis)

  expect(res).toBe(true)
})

test("API returns failed response", async () => {
  jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValue({});

  const res = await hwUtils.waitForNewTransaction(envs, hwRedis)
  expect(res).toBe(false)
})

test("singAndSendTx returns empty object", async () => {
  jest.spyOn(hwUtils.ComakeryApi.prototype, "getNextTransactionToSign").mockReturnValue({ txHash: "TXHASH" });
  jest.spyOn(hwUtils, "singAndSendTx").mockReturnValue({});

  const res = await hwUtils.waitForNewTransaction(envs, hwRedis)
  expect(res).toBe(false)
})

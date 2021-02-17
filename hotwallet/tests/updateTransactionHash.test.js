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
const blockchainTransaction = { id: 99, network: "algorand_test", txHash: "TXHASH" }

jest.mock("axios")

test("API returns a blockchain transaction", async () => {
  expect.assertions(1)
  axios.put.mockImplementation(() => Promise.resolve({ status: 200, data: blockchainTransaction }))
  res = await hwUtils.updateTransactionHash(blockchainTransaction, envs)

  expect(res).toEqual(blockchainTransaction)
})

test("API returns failed response", async () => {
  const data = {
    response: {
      status: 500,
      statusText: "Server error",
      data: { errors: { any: "error" } }
    }
  }

  axios.put.mockReturnValue(Promise.reject(data));
  res = await hwUtils.updateTransactionHash(blockchainTransaction, envs)

  expect(res).toEqual({})
})

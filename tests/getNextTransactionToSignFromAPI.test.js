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
const wallet = { address: "YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4", mnemonic: "mnemonic phrase" }
const blockchainTransaction = { id: 99, network: "algorand_test" }

jest.mock("axios")

test("API returns empty response", async () => {
  expect.assertions(1);
  axios.post.mockImplementation(() => Promise.resolve({ status: 204, data: null }))
  res = await hwUtils.getNextTransactionToSignFromAPI(wallet.address, envs)

  expect(res).toEqual({})
})

test("API returns a blockchain transaction", async () => {
  expect.assertions(1);
  axios.post.mockImplementation(() => Promise.resolve({ status: 201, data: blockchainTransaction }))
  res = await hwUtils.getNextTransactionToSignFromAPI(wallet.address, envs)

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

  axios.post.mockReturnValue(Promise.reject(data));
  res = await hwUtils.getNextTransactionToSignFromAPI(wallet.address, envs)

  expect(res).toEqual({})
})

const axios = require("axios")
const redis = require("redis")
const hwUtils = require("../lib/hotwalletUtils")
const envs = {
  projectId: "1",
  projectApiKey: "project_api_key",
  comakeryServerUrl: null,
  purestakeApi: "purestake_api_key",
  redisUrl: "redis://localhost:6379/0"
}
const wallet = { address: "YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4", mnemonic: "mnemonic phrase" }

jest.mock("axios")

const redisClient = redis.createClient()

beforeEach(async () => {
  await hwUtils.deleteCurrentKey(envs, redisClient)
})

afterAll(() => {
  redisClient.quit()
});

test("API returns successfull response", async () => {
  expect.assertions(1);
  axios.post.mockImplementation(() => Promise.resolve({ status: 201, data: {} }))
  res = await hwUtils.registerHotWallet(wallet, envs, redisClient)

  expect(res).toBe(true)
})

test("API returns failed response", async () => {
  const data = {
    response: {
      status: 422,
      statusText: "Unprocessable Entity",
      data: { errors: { hot_wallet: 'already exists' } }
    }
  }

  axios.post.mockReturnValue(Promise.reject(data));
  res = await hwUtils.registerHotWallet(wallet, envs, redisClient)

  expect(res).toBe(false)
})

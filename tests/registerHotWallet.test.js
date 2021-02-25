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
const wallet = new hwUtils.HotWallet("YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4", "mnemonic phrase")

jest.mock("axios")

const redisClient = redis.createClient()
const hwRedis = new hwUtils.HotWalletRedis(envs, redisClient)
const hwApi = new hwUtils.ComakeryApi(envs)

beforeEach(async () => {
  await hwRedis.deleteCurrentKey()
})

afterAll(() => {
  redisClient.quit()
});

test("API returns successfull response", async () => {
  expect.assertions(1);
  axios.post.mockImplementation(() => Promise.resolve({ status: 201, data: {} }))
  res = await hwApi.registerHotWallet(wallet)

  expect(res.status).toEqual(201)
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
  res = await hwApi.registerHotWallet(wallet)

  expect(res).toBe(false)
})

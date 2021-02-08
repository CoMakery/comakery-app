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

jest.mock("axios")

const redisClient = redis.createClient();

afterAll(() => {
  redisClient.quit()
});

test("return successfull response", async () => {
  expect.assertions(1);
  const wallet = { address: "YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4", mnemonic: "mnemonic phrase" }
  axios.post.mockImplementation(() => Promise.resolve({ status: 201, data: { qwe: "qwe" } }))
  res = await hwUtils.registerHotWallet(wallet, envs, redisClient)

  expect(res).toBe(true)
})

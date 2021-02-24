const { promisify } = require("util")
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

beforeEach(async () => {
  await hwUtils.deleteCurrentKey(envs, redisClient)
})

afterAll(() => {
  redisClient.quit()
})

test("successfully writed keys to redis", async () => {
  axios.post.mockImplementation(() => Promise.resolve({ status: 201, data: {} }))
  res = await hwUtils.hotWalletInitialization(envs, redisClient)

  expect(res).toBe(true)

  const storedKeys = promisify(redisClient.hgetall).bind(redisClient);
  const keys = await storedKeys(hwUtils.keyName(envs.projectId))
  expect(keys.address.length).toEqual(58)
  expect(keys.mnemonic.length).toBeGreaterThan(100)
})

test("don't overwrite existing keys", async () => {
  const keyName = hwUtils.keyName(envs.projectId)
  const wallet = { address: "YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4", mnemonic: "mnemonic phrase" }
  const hset = promisify(redisClient.hset).bind(redisClient);
  await hset(keyName, "address", wallet.address, "mnemonic", wallet.mnemonic)

  res = await hwUtils.hotWalletInitialization(envs, redisClient)
  expect(res).toBe(true)

  const storedKeys = promisify(redisClient.hgetall).bind(redisClient);
  const keys = await storedKeys(keyName)
  expect(keys.address).toEqual(wallet.address)
  expect(keys.mnemonic).toEqual(wallet.mnemonic)
})

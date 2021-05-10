const { promisify } = require("util")
const axios = require("axios")
const redis = require("redis")
const hwUtils = require("../lib/hotwalletUtils")
const envs = {
  projectId: "1",
  projectApiKey: "project_api_key",
  comakeryServerUrl: null,
  purestakeApi: "purestake_api_key",
  redisUrl: "redis://localhost:6379/0",
}
jest.mock("axios")

describe("Hot Wallet initialization suite", () => {
  const algoEnvs = envs
  algoEnvs.blockchainNetwork = "algorand_test"
  const ethEnvs = envs
  ethEnvs.blockchainNetwork = "ethereum_ropsten"

  const redisClient = redis.createClient()
  const hwRedis = new hwUtils.HotWalletRedis(envs, redisClient)
  const algorandWalletKeys = {
    publicKey: "057bac3f6921e98a89a3bfe2b2ec138577da66ee58329b741e44de93431f8bde",
    privateKey: "fb2c017e4b6ab9c8c6cf7513223f5cd0b493c249a39a68cd29b26d37274bad29057bac3f6921e98a89a3bfe2b2ec138577da66ee58329b741e44de93431f8bde",
    privateKeyEncrypted: "Z6mKYt1ntc+s1xQkK4HYKZtUsK4Kdg18kOa2p2SL6H0Q4GO0pafso6fEEmQgDoiakzj3lfqp3s5/1kEjNZomWm1h8xdwbBHUT4rrrTfohjdPZAe5Fg1Sw/6hA+mm7dKN8eWzEFaNe7LIdFrzHD0bOz5OSif8+t3QGmQfrbVulRakLfBh5tc6MVOsAMAt57d6nXUhaQfwPtuDB41bPoMRmAYrwjKrTmiu"
  }
  const ethWalletKeys = {
    publicKey: "057bac3f6921e98a89a3bfe2b2ec138577da66ee58329b741e44de93431f8bde",
    privateKey: "fb2c017e4b6ab9c8c6cf7513223f5cd0b493c249a39a68cd29b26d37274bad29057bac3f6921e98a89a3bfe2b2ec138577da66ee58329b741e44de93431f8bde",
    privateKeyEncrypted: "Z6mKYt1ntc+s1xQkK4HYKZtUsK4Kdg18kOa2p2SL6H0Q4GO0pafso6fEEmQgDoiakzj3lfqp3s5/1kEjNZomWm1h8xdwbBHUT4rrrTfohjdPZAe5Fg1Sw/6hA+mm7dKN8eWzEFaNe7LIdFrzHD0bOz5OSif8+t3QGmQfrbVulRakLfBh5tc6MVOsAMAt57d6nXUhaQfwPtuDB41bPoMRmAYrwjKrTmiu"
  }
  const algorandHW = new hwUtils.HotWallet("algorand_test", "AV52YP3JEHUYVCNDX7RLF3ATQV35UZXOLAZJW5A6ITPJGQY7RPPKRRMHNY", algorandWalletKeys)
  const ethHW = new hwUtils.HotWallet("ethereum_ropsten", "0x2aA78Db0BEff941883C33EA150ed86eaDE09A377", ethWalletKeys)

  beforeEach(async () => {
    await hwRedis.deleteCurrentKey()
  })

  afterAll(() => {
    redisClient.quit()
  })

  test("algorand wallet: successfully writed keys to redis", async () => {
    jest.spyOn(hwUtils.Blockchain.prototype, "generateNewWallet").mockReturnValue(algorandHW)
    axios.post.mockImplementation(() => Promise.resolve({ status: 201, data: {} }))

    res = await hwUtils.hotWalletInitialization(algoEnvs, redisClient)

    expect(res).toBe(true)

    const storedKeys = promisify(redisClient.hgetall).bind(redisClient);
    const keys = await storedKeys(hwRedis.walletKeyName())
    expect(keys.address).toEqual(algorandHW.address)
    expect(keys.publicKey).toEqual(algorandHW.publicKey)
    expect(keys.privateKey).toEqual(algorandHW.privateKey)
    expect(keys.privateKeyEncrypted).toEqual(algorandHW.privateKeyEncrypted)

    await hwRedis.deleteCurrentKey()
  })

  test("algorand wallet: don't overwrite existing keys", async () => {
    const keyName = hwRedis.walletKeyName()
    const hset = promisify(redisClient.hset).bind(redisClient);
    await hset(keyName, "address", "AV52YP3JEHUYVCNDX7RLF3ATQV35UZXOLAZJW5A6ITPJGQY7RPPKRRMHNY", "publicKey", algorandWalletKeys.publicKey, "privateKey", algorandWalletKeys.privateKey, "privateKeyEncrypted", algorandWalletKeys.privateKeyEncrypted)

    res = await hwUtils.hotWalletInitialization(algoEnvs, redisClient)
    expect(res).toBe(true)

    const storedKeys = promisify(redisClient.hgetall).bind(redisClient);
    const keys = await storedKeys(keyName)
    expect(keys.address).toEqual("AV52YP3JEHUYVCNDX7RLF3ATQV35UZXOLAZJW5A6ITPJGQY7RPPKRRMHNY")
    expect(keys.publicKey).toEqual(algorandWalletKeys.publicKey)
    expect(keys.privateKey).toEqual(algorandWalletKeys.privateKey)
    expect(keys.privateKeyEncrypted).toEqual(algorandWalletKeys.privateKeyEncrypted)
  })

  test("ethereum wallet: successfully writed keys to redis", async () => {
    jest.spyOn(hwUtils.Blockchain.prototype, "generateNewWallet").mockReturnValue(ethHW)
    axios.post.mockImplementation(() => Promise.resolve({ status: 201, data: {} }))

    res = await hwUtils.hotWalletInitialization(ethEnvs, redisClient)

    expect(res).toBe(true)

    const storedKeys = promisify(redisClient.hgetall).bind(redisClient);
    const keys = await storedKeys(hwRedis.walletKeyName())
    expect(keys.address).toEqual(ethHW.address)
    expect(keys.publicKey).toEqual(ethHW.publicKey)
    expect(keys.privateKey).toEqual(ethHW.privateKey)
    expect(keys.privateKeyEncrypted).toEqual(ethHW.privateKeyEncrypted)
  })

  test("ethereum wallet: don't overwrite existing keys", async () => {
    const keyName = hwRedis.walletKeyName()
    const hset = promisify(redisClient.hset).bind(redisClient);
    await hset(keyName, "address", ethHW.address, "publicKey", ethHW.publicKey, "privateKey", ethHW.privateKey, "privateKeyEncrypted", ethHW.privateKeyEncrypted)

    res = await hwUtils.hotWalletInitialization(ethEnvs, redisClient)
    expect(res).toBe(true)

    const storedKeys = promisify(redisClient.hgetall).bind(redisClient);
    const keys = await storedKeys(keyName)
    expect(keys.address).toEqual(ethHW.address)
    expect(keys.publicKey).toEqual(ethHW.publicKey)
    expect(keys.privateKey).toEqual(ethHW.privateKey)
    expect(keys.privateKeyEncrypted).toEqual(ethHW.privateKeyEncrypted)
  })
});

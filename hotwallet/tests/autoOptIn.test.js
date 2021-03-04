const redis = require("redis")
const hwUtils = require("../lib/hotwalletUtils")
const envs = {
  projectId: "1",
  projectApiKey: "project_api_key",
  comakeryServerUrl: null,
  purestakeApi: "purestake_api_key",
  redisUrl: "redis://localhost:6379/0",
  checkForNewTransactionsDelay: 30,
  optInApp: 13997710,
  blockchainNetwork: "algorand_test"
}

const redisClient = redis.createClient()
const hwRedis = new hwUtils.HotWalletRedis(envs, redisClient)

beforeEach(async () => {
  await hwRedis.deleteCurrentKey()
  const wallet = new hwUtils.HotWallet("YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4", "mnemonic phrase")
  await hwRedis.saveNewHotWallet(wallet)
})

afterAll(() => {
  redisClient.quit()
  jest.restoreAllMocks()
});

test("with stored opt-in apps in Redis", async () => {
  await hwRedis.saveOptedInApps([13997710])

  // Initially have opt-ins in Redis
  hw = await hwRedis.hotWallet()
  expect(hw.optedInApps).toEqual([13997710])

  res = await hwUtils.autoOptIn(envs, hwRedis)

  expect(res).toEqual([13997710])
})

test("with opt-in exists on blockchain", async () => {
  let hw = await hwRedis.hotWallet()
  expect(hw.optedInApps).toEqual([])

  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isOptedInToCurrentApp").mockImplementation(() => {return true});
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "getOptedInAppsForHotWallet").mockImplementation(() => {return [13997710]});

  res = await hwUtils.autoOptIn(envs, hwRedis)

  expect(res).toEqual([13997710])
  // saved to Redis
  hw = await hwRedis.hotWallet()
  expect(hw.optedInApps).toEqual([13997710])
})

test("with wallet with enough amount to opt-in", async () => {
  let hw = await hwRedis.hotWallet()
  expect(hw.optedInApps).toEqual([])

  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "isOptedInToCurrentApp").mockImplementation(() => {return false});
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "enoughBalanceToOptInForHotWallet").mockImplementation(() => {return true});
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "optInToApp").mockImplementation(() => { return { tx: true} });
  jest.spyOn(hwUtils.AlgorandBlockchain.prototype, "getOptedInAppsForHotWallet").mockImplementation(() => {return [13997710]});

  res = await hwUtils.autoOptIn(envs, hwRedis)

  expect(res).toEqual([13997710])
  // saved to Redis
  hw = await hwRedis.hotWallet()
  expect(hw.optedInApps).toEqual([13997710])
})

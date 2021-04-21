const hwUtils = require("../lib/hotwalletUtils")
const envs = {
  projectId: "1",
  projectApiKey: "project_api_key",
  comakeryServerUrl: null,
  purestakeApi: "eE7U9NAUNh1VlvDyZARGP4F2CIZgBDDB5nhxAS3G",
  redisUrl: "redis://localhost:6379/0",
  checkForNewTransactionsDelay: 30,
  optInApp: 13997710,
  blockchainNetwork: "algorand_test"
}

describe("Get OptedInapps for hot wallet suite", () => {
  const hwAddress = "YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4"

  afterEach(() => {
    jest.restoreAllMocks()
  })

  test("when blockchain returns opted-in apps", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    jest.spyOn(hwAlgorand, "connect").mockReturnValue(true)
    jest.spyOn(hwAlgorand, "getOptedInAppsFromBlockchain").mockReturnValue([13997710])

    res = await hwAlgorand.getOptedInAppsForHotWallet(hwAddress)

    expect(res).toEqual([13997710])
  })

  test("when blockchain returns no apps", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    jest.spyOn(hwAlgorand, "connect").mockReturnValue(true)
    jest.spyOn(hwAlgorand, "getOptedInAppsFromBlockchain").mockReturnValue([])

    res = await hwAlgorand.getOptedInAppsForHotWallet(hwAddress)

    expect(res).toEqual([])
  })
});


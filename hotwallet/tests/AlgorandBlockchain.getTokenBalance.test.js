const hwUtils = require("../lib/hotwalletUtils")
const envs = {
  projectId: "1",
  projectApiKey: "project_api_key",
  comakeryServerUrl: null,
  purestakeApi: "purestake_api_key",
  redisUrl: "redis://localhost:6379/0",
  emptyQueueDelay: 30,
  optInApp: 13997710,
  blockchainNetwork: "algorand_test"
}

describe("Get token balance",  () => {
  const hwAddress = "YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4"

  afterAll(() => {
    jest.restoreAllMocks()
  })

  test("return actual amount from blockchain", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    const localState = {
      deleted: false,
      id: 13997710,
      'key-value': [
        { key: 'YmFsYW5jZQ==', value: { bytes: '', type: 2, uint: 99 } }, // balance here
        { key: 'bG9ja1VudGls', value: { bytes: '', type: 2, uint: 0 } },
        { key: 'bWF4QmFsYW5jZQ==', value: { bytes: '', type: 2, uint: 0 } },
        { key: 'dHJhbnNmZXJHcm91cA==', value: { bytes: '', type: 2, uint: 1 } }
      ],
      'opted-in-at-round': 12725706,
      schema: { 'num-byte-slice': 8, 'num-uint': 8 }
    }
    jest.spyOn(hwAlgorand, "getAppLocalState").mockReturnValueOnce(localState)

    res = await hwAlgorand.getTokenBalance(hwAddress)

    expect(res).toEqual(99)

    // result cached
    res = await hwAlgorand.getTokenBalance(hwAddress)
    expect(res).toEqual(99)
  })

  test("when local state is empty", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    const localState = {}
    jest.spyOn(hwAlgorand, "getAppLocalState").mockReturnValueOnce(localState)

    res = await hwAlgorand.getTokenBalance(hwAddress)


    expect(res).toEqual(0)
  })

  test("when local state does not have balance", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    const localState = {
      deleted: false,
      id: 13997710,
      'key-value': [],
      'opted-in-at-round': 12725706,
      schema: { 'num-byte-slice': 8, 'num-uint': 8 }
    }
    jest.spyOn(hwAlgorand, "getAppLocalState").mockReturnValueOnce(localState)

    res = await hwAlgorand.getTokenBalance(hwAddress, 13997710)


    expect(res).toEqual(0)
  })

  test("when local state does not have balance", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    const localState = {
      deleted: false,
      id: 13997710,
      'key-value': [{ key: 'bWF4QmFsYW5jZQ==', value: { bytes: '', type: 2, uint: 0 } }],
      'opted-in-at-round': 12725706,
      schema: { 'num-byte-slice': 8, 'num-uint': 8 }
    }
    jest.spyOn(hwAlgorand, "getAppLocalState").mockReturnValueOnce(localState)

    res = await hwAlgorand.getTokenBalance(hwAddress, 13997710)


    expect(res).toEqual(0)
  })
});

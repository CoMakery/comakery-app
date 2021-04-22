const hwUtils = require("../lib/hotwalletUtils")
const envs = {
  projectId: "1",
  projectApiKey: "project_api_key",
  comakeryServerUrl: null,
  purestakeApi: "purestake_api_key",
  redisUrl: "redis://localhost:6379/0",
  checkForNewTransactionsDelay: 30,
  optInApp: 13997710,
  blockchainNetwork: "algorand_test",
}

describe("Is transaction valid test suite", () => {
  const hwAddress = "YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4"
  // transfer 5 tokens
  const testTx = '{"type":"appl","from":"5CNLUUIIKC52MNNEUAJD6QZDVBQJWQD2M5N2MHDQ6M3Y372WWUJCYQXUUU","appIndex":13997710,"appAccounts":["U7A22RJ53S2G2MOW5JZLPFDLT4IKABMPBUQW2BHW5HSAYUP76CQKCPB7MQ"],"appArgs":["0x7472616e73666572","0x05"],"appOnComplete":0}'

  afterAll(() => {
    jest.restoreAllMocks()
  })

  test("valid", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(5)

    res = await hwAlgorand.isTransactionValid(testTx, hwAddress)

    expect(res).toEqual({ valid: true })
  })

  test("valid: maxAmountForTransfer is 0", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(Object.assign(envs, { maxAmountForTransfer: 0 }))
    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(5)

    res = await hwAlgorand.isTransactionValid(testTx, hwAddress)

    expect(res).toEqual({ valid: true })
  })

  test("invalid: empty transaction", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    const wrongAppTx = undefined

    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(4)

    res = await hwAlgorand.isTransactionValid(wrongAppTx, hwAddress)

    expect(res).toEqual({ valid: false })
  })

  test("invalid: tx is incorrect JSON", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    const wrongAppTx = '[123'

    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(4)

    res = await hwAlgorand.isTransactionValid(wrongAppTx, hwAddress)

    expect(res).toEqual({ valid: false, markAs: "failed", error: "Unknown error: SyntaxError: Unexpected end of JSON input" })
  })

  test("invalid: transaction for another app", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    const wrongAppTx = '{"type":"appl","from":"5CNLUUIIKC52MNNEUAJD6QZDVBQJWQD2M5N2MHDQ6M3Y372WWUJCYQXUUU","appIndex":93997710,"appAccounts":["U7A22RJ53S2G2MOW5JZLPFDLT4IKABMPBUQW2BHW5HSAYUP76CQKCPB7MQ"],"appArgs":["0x7472616e73666572","0x05"],"appOnComplete":0}'

    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(4)

    res = await hwAlgorand.isTransactionValid(wrongAppTx, hwAddress)

    expect(res).toEqual({ valid: false, markAs: "failed", error: "The transaction is not for configured App." })
  })

  test("invalid: HW has not enough tokens to transfer", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(4)

    res = await hwAlgorand.isTransactionValid(testTx, hwAddress)

    expect(res).toEqual({ valid: false, markAs: "cancelled", error: "The Hot Wallet has insufficient tokens to transfer (4 < 5)" })
  })

  test("invalid: limited by maxAmountForTransfer", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(Object.assign(envs, { maxAmountForTransfer: 4 }))
    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(5)

    res = await hwAlgorand.isTransactionValid(testTx, hwAddress)

    expect(res).toEqual({ valid: false, markAs: "failed", error: "The transaction has too big amount for transfer (5). Max amount is 4" })
  })
});


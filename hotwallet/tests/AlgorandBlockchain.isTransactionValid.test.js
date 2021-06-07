const hwUtils = require("../lib/hotwalletUtils")
const blockchainTransaction = require('./fixtures/algorandBlockchainTransaction').blockchainTransaction

const envs = {
  projectId: "1",
  projectApiKey: "project_api_key",
  comakeryServerUrl: null,
  purestakeApi: "purestake_api_key",
  redisUrl: "redis://localhost:6379/0",
  emptyQueueDelay: 30,
  optInApp: 13997710,
  blockchainNetwork: "algorand_test",
}

describe("Is transaction valid test suite", () => {
  const hwAddress = "YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4"

  afterAll(() => {
    jest.restoreAllMocks()
  })

  test("valid", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(5)

    res = await hwAlgorand.isTransactionValid(blockchainTransaction, hwAddress)

    expect(res).toEqual({ valid: true })
  })

  test("valid: maxAmountForTransfer is 0", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(Object.assign(envs, { maxAmountForTransfer: 0 }))
    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(5)

    res = await hwAlgorand.isTransactionValid(blockchainTransaction, hwAddress)

    expect(res).toEqual({ valid: true })
  })

  test("invalid: empty transaction", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    const wrongAppTx = { ...blockchainTransaction }
    wrongAppTx.txRaw = undefined

    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(4)

    res = await hwAlgorand.isTransactionValid(wrongAppTx, hwAddress)

    expect(res).toEqual({ valid: false })
  })

  test("invalid: tx is incorrect JSON", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    const wrongAppTx = { ...blockchainTransaction }
    wrongAppTx.txRaw = '[123'

    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(4)

    res = await hwAlgorand.isTransactionValid(wrongAppTx, hwAddress)

    expect(res).toEqual({ valid: false, markAs: "failed", error: "Unknown error: SyntaxError: Unexpected end of JSON input" })
  })

  test("invalid: transaction for another app", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    const wrongAppTx = { ...blockchainTransaction }
    txRaw = JSON.parse(blockchainTransaction.txRaw)
    txRaw.appIndex = 93997710
    wrongAppTx.txRaw = JSON.stringify(txRaw)

    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(4)

    res = await hwAlgorand.isTransactionValid(wrongAppTx, hwAddress)

    expect(res).toEqual({ valid: false, markAs: "failed", error: "The transaction is not for configured App." })
  })

  test("invalid: HW has not enough tokens to transfer", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)
    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(4)

    res = await hwAlgorand.isTransactionValid(blockchainTransaction, hwAddress)

    expect(res).toEqual({ valid: false, markAs: "cancelled", error: "The Hot Wallet has insufficient tokens to transfer (4 < 5)" })
  })

  test("invalid: limited by maxAmountForTransfer", async () => {
    const hwAlgorand = new hwUtils.AlgorandBlockchain(Object.assign(envs, { maxAmountForTransfer: 4 }))
    jest.spyOn(hwAlgorand, "getTokenBalance").mockReturnValueOnce(5)

    res = await hwAlgorand.isTransactionValid(blockchainTransaction, hwAddress)

    expect(res).toEqual({ valid: false, markAs: "failed", error: "The transaction has too big amount for transfer (5). Max amount is 4" })
  })
});


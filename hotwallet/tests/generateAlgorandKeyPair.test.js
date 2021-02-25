const hwUtils = require('../lib/hotwalletUtils')
const hwAlgorand = new hwUtils.AlgorandBlockchain()

test('return correct generated keys', async () => {
  const keys = hwAlgorand.generateAlgorandKeyPair()
  expect(keys).toBeInstanceOf(hwUtils.HotWallet)
  expect(Object.keys(keys)).toEqual(["address", "mnemonic"])
  expect(keys.address).toBeDefined()
  expect(keys.address.length).toBe(58)
  expect(keys.mnemonic).toBeDefined()
  expect(keys.mnemonic.length).toBeGreaterThan(100)
})

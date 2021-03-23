const hwUtils = require('../lib/hotwalletUtils')
const envs = {
  blockchainNetwork: 'algorand_test'
}
const hwAlgorand = new hwUtils.AlgorandBlockchain(envs)

test('return correct generated keys', async () => {
  const keys = hwAlgorand.generateAlgorandKeyPair()
  expect(keys).toBeInstanceOf(hwUtils.HotWallet)
  expect(Object.keys(keys)).toEqual(["klass", "address", "mnemonic", "optedInApps"])
  expect(keys.address).toBeDefined()
  expect(keys.address.length).toBe(58)
  expect(keys.mnemonic).toBeDefined()
  expect(keys.mnemonic.length).toBeGreaterThan(100)
  expect(keys.optedInApps).toEqual([])
})

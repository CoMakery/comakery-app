const hwUtils = require('../lib/hotwalletUtils')

test('return correct generated keys', async () => {
  const keys = hwUtils.generateAlgorandKeyPair()
  expect(Object.keys(keys)).toEqual(["address", "mnemonic"])
  expect(keys.address).toBeDefined()
  expect(keys.address.length).toBe(58)
  expect(keys.mnemonic).toBeDefined()
  expect(keys.mnemonic.length).toBeGreaterThan(100)
})

const hwUtils = require('../lib/hotwalletUtils')

describe("Blockchain generate new wallet test suite", () => {
  test('return correct generated keys for algorand ', async () => {
    const algoBlockchain = new hwUtils.Blockchain({
      purestakeApi: "eE7U9NAUNh1VlvDyZARGP4F2CIZgBDDB5nhxAS3G",
      blockchainNetwork: 'algorand_test'
    })

    const keys = await algoBlockchain.generateNewWallet()
    expect(keys).toBeInstanceOf(hwUtils.HotWallet)
    expect(Object.keys(keys)).toEqual(["klass", "address", "publicKey", "privateKey", "privateKeyEncrypted"])
    expect(keys.address).toBeDefined()
    expect(keys.address.length).toBe(58)
    expect(keys.publicKey).toBeDefined()
    expect(keys.privateKey).toBeDefined()
    expect(keys.privateKeyEncrypted).toBeDefined()
    expect(keys.privateKeyEncrypted).toBeDefined()
  })

  test('return correct generated keys for ethereum ', async () => {
    const ethBlockchain = new hwUtils.Blockchain({
      infuraProjectId: "39f6ad316c5a4b87a0f90956333c3666",
      blockchainNetwork: 'ethereum_ropsten'
    })

    const keys = await ethBlockchain.generateNewWallet()
    expect(keys).toBeInstanceOf(hwUtils.HotWallet)
    expect(Object.keys(keys)).toEqual(["klass", "address", "publicKey", "privateKey", "privateKeyEncrypted"])
    expect(keys.address).toBeDefined()
    expect(keys.address.length).toBe(42)
    expect(keys.publicKey).toBeDefined()
    expect(keys.privateKey).toBeDefined()
    expect(keys.privateKeyEncrypted).toBeDefined()
    expect(keys.privateKeyEncrypted).toBeDefined()
  })
});

class AlgorandHotWallet {
  constructor(network, address, keys, optedInApps = []) {
    this.network = network
    this.address = address
    this.privateKey = keys.privateKey
    this.publicKey = keys.publicKey
    this.privateKeyEncrypted = keys.privateKeyEncrypted
    this.optedInApps = optedInApps
  }

  isOptedInToApp(appIndexToCheck) {
    if (!this.optedInApps) { return false }
    return this.optedInApps.includes(appIndexToCheck)
  }

  secretKey() {
    this.keys.privateKey
  }
}
exports.AlgorandHotWallet = AlgorandHotWallet

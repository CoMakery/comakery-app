const algosdk = require("algosdk")

class AlgorandHotWallet {
  constructor(network, address, mnemonic, optedInApps = []) {
    this.network = network
    this.address = address
    this.mnemonic = mnemonic
    this.optedInApps = optedInApps
  }

  isOptedInToApp(appIndexToCheck) {
    if (!this.optedInApps) { return false }
    return this.optedInApps.includes(appIndexToCheck)
  }

  secretKey() {
    const { sk } = algosdk.mnemonicToSecretKey(this.mnemonic)
    return sk
  }
}
exports.AlgorandHotWallet = AlgorandHotWallet

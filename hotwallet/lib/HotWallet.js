const algosdk = require("algosdk")

class HotWallet {
  constructor(address, mnemonic, optedInApps = []) {
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
exports.HotWallet = HotWallet

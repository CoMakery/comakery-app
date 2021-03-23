class EthereumHotWallet {
  constructor(network, address, mnemonic, optedInApps = []) {
    this.network = network
    this.address = address
    this.mnemonic = mnemonic
    this.optedInApps = optedInApps
  }

  isOptedInToApp() {
    return true
  }

  secretKey() {
    // const { sk } = algosdk.mnemonicToSecretKey(this.mnemonic)
    // return sk
    // TODO: Implement me
  }
}

exports.EthereumHotWallet = EthereumHotWallet

class EthereumHotWallet {
  constructor(network, address, keys, optedInApps = []) {
    this.network = network
    this.address = address
    this.privateKey = keys.privateKey
    this.publicKey = keys.publicKey
    this.privateKeyEncrypted = keys.privateKeyEncrypted
    this.optedInApps = optedInApps
  }

  isReadyToSendTx() {
    return true
  }
}

exports.EthereumHotWallet = EthereumHotWallet

const AlgorandHotWallet = require("./AlgorandHotWallet").AlgorandHotWallet
const EthereumHotWallet = require("./EthereumHotWallet").EthereumHotWallet

class HotWallet {
  constructor(network, address, keys, optedInApps = []) {
    if (["algorand", "algorand_test", "algorand_beta"].indexOf(network) > -1) {
      this.klass = new AlgorandHotWallet(network, address, keys, optedInApps)
    } else if (["ethereum", "ethereum_ropsten"].indexOf(network) > -1) {
      this.klass = new EthereumHotWallet(network, address, keys, optedInApps)
    } else {
      this.klass = undefined
    }

    this.address = this.klass.address
    this.publicKey = keys.publicKey
    this.privateKey = keys.privateKey
    this.privateKeyEncrypted = keys.privateKeyEncrypted
    this.optedInApps = this.klass.optedInApps
  }

  isOptedInToApp(appIndexToCheck) {
    return this.klass.isOptedInToApp(appIndexToCheck)
  }
}
exports.HotWallet = HotWallet

const AlgorandHotWallet = require("./AlgorandHotWallet").AlgorandHotWallet
const EthereumHotWallet = require("./EthereumHotWallet").EthereumHotWallet

class HotWallet {
  constructor(network, address, mnemonic, optedInApps = []) {
    if (["algorand", "algorand_test", "algorand_beta"].indexOf(network) > -1) {
      this.klass = new AlgorandHotWallet(network, address, mnemonic, optedInApps)
    } else if (["ethereum", "ethereum_ropsten"].indexOf(network) > -1) {
      this.klass = new EthereumHotWallet(network, address, mnemonic, optedInApps)
    } else {
      this.klass = undefined
    }

    this.address = this.klass.address
    this.mnemonic = this.klass.mnemonic
    this.optedInApps = this.klass.optedInApps
  }

  isOptedInToApp(appIndexToCheck) {
    return this.klass.isOptedInToApp(appIndexToCheck)
  }

  secretKey() {
    return this.klass.secretKey()
  }
}
exports.HotWallet = HotWallet

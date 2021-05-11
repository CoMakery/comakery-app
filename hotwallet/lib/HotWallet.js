const AlgorandHotWallet = require("./AlgorandHotWallet").AlgorandHotWallet
const EthereumHotWallet = require("./EthereumHotWallet").EthereumHotWallet

class HotWallet {
  constructor(network, address, keys, options = {}) {
    if (["algorand", "algorand_test", "algorand_beta"].indexOf(network) > -1) {
      this.klass = new AlgorandHotWallet(network, address, keys, options)
    } else if (["ethereum", "ethereum_ropsten", "ethereum_rinkeby"].indexOf(network) > -1) {
      this.klass = new EthereumHotWallet(network, address, keys, options)
    } else {
      this.klass = undefined
    }

    this.address = this.klass.address
    this.publicKey = keys.publicKey
    this.privateKey = keys.privateKey
    this.privateKeyEncrypted = keys.privateKeyEncrypted
  }

  isReadyToSendTx(envs) {
    return this.klass.isReadyToSendTx(envs)
  }

  isEthereum() {
    return this.klass.constructor.name === "EthereumHotWallet"
  }
}
exports.HotWallet = HotWallet

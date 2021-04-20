const AlgorandBlockchain = require("./blockchains/AlgorandBlockchain").AlgorandBlockchain
const EthereumBlockchain = require("./blockchains/EthereumBlockchain").EthereumBlockchain

class Blockchain {
  constructor(envs) {
    this.envs = envs
    this.blockchainNetwork = envs.blockchainNetwork
    if (["algorand", "algorand_test", "algorand_beta"].indexOf(this.blockchainNetwork) > -1) {
      this.klass = new AlgorandBlockchain(this.envs)
    } else if (["ethereum", "ethereum_ropsten"].indexOf(this.blockchainNetwork) > -1) {
      this.klass = new EthereumBlockchain(this.envs)
    } else {
      this.klass = undefined
    }
  }

  async generateNewWallet() {
    return await this.klass.generateNewWallet()
  }

  async enoughCoinBalanceToSendTransaction(hotWalletAddress) {
    return await this.klass.enoughCoinBalanceToSendTransaction(hotWalletAddress)
  }

  async positiveTokenBalance(hotWalletAddress) {
    return await this.klass.positiveTokenBalance(hotWalletAddress)
  }

  async isTransactionValid(transaction, hotWalletAddress) {
    return await this.klass.isTransactionValid(transaction, hotWalletAddress)
  }

  async signAndSendTransaction(transaction, hotWallet) {
    return await this.klass.signAndSendTransaction(transaction, hotWallet)
  }
}
exports.Blockchain = Blockchain
exports.AlgorandBlockchain = AlgorandBlockchain
exports.EthereumBlockchain = EthereumBlockchain

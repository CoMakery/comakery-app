
const axios = require("axios")

class ComakeryApi {
  constructor(envs) {
    this.envs = envs
  }

  async registerHotWallet(wallet) {
    const registerHotWalletUrl = `${this.envs.comakeryServerUrl}/api/v1/projects/${this.envs.projectId}/hot_wallet_addresses`
    const params = { body: { data: { hot_wallet: { address: wallet.address } } } }
    const config = { headers: { "API-Transaction-Key": this.envs.projectApiKey } }

    try {
      return await axios.post(registerHotWalletUrl, params, config)
    } catch (error) {
      this.logError('registerHotWallet', error)
      return {}
    }
  }

  async getNextTransactionToSign(hotWalletAddress) {
    const blockchainTransactionsUrl = `${this.envs.comakeryServerUrl}/api/v1/projects/${this.envs.projectId}/blockchain_transactions`
    const params = { body: { data: { transaction: { source: hotWalletAddress } } } }
    const config = { headers: { "API-Transaction-Key": this.envs.projectApiKey } }

    try {
      const res = await axios.post(blockchainTransactionsUrl, params, config)
      if (res.status == 201) {
        return res.data
      } else {
        return {}
      }
    } catch (error) {
      this.logError('getNextTransactionToSign', error)
      return {}
    }
  }

  async updateTransactionHash(blockchainTransaction) {
    const blockchainTransactionsUrl = `${this.envs.comakeryServerUrl}/api/v1/projects/${this.envs.projectId}/blockchain_transactions/${blockchainTransaction.id}`
    const params = { body: { data: { transaction: { tx_hash: blockchainTransaction.txHash } } } }
    const config = { headers: { "API-Transaction-Key": this.envs.projectApiKey } }

    try {
      const res = await axios.put(blockchainTransactionsUrl, params, config)
      if (res.status == 200) {
        console.log("Transaction hash was successfully updated")
        return res.data
      } else {
        return {}
      }
    } catch (error) {
      this.logError('updateTransactionHash', error)
      return {}
    }
  }

  async cancelTransaction(blockchainTransaction, errorMessage, status ) {
    const blockchainTransactionsUrl = `${this.envs.comakeryServerUrl}/api/v1/projects/${this.envs.projectId}/blockchain_transactions/${blockchainTransaction.id}`
    let transactionParams = { status_message: errorMessage }
    if (status == "failed") { transactionParams["failed"] = true }
    const params = { body: { data: { transaction: transactionParams } } }
    const config = { data: params, headers: { "API-Transaction-Key": this.envs.projectApiKey } }

    try {
      const res = await axios.delete(blockchainTransactionsUrl, config)
      if (res.status == 200) {
        console.log(`The transaction has been marked as ${status}`)
        return res.data
      } else {
        return {}
      }
    } catch (error) {
      this.logError('cancelTransaction', error)
      return {}
    }
  }

  logError(functionName, error) {
    console.error(`${functionName} API call failed with:\n`)

    if (error.response) {
      console.error(
        `${error.response.status} (${error.response.statusText}) data:\n`,
        error.response.data
      )
    } else {
      console.error(`${functionName} produced an unknown error on API call`)
    }
  }
}
exports.ComakeryApi = ComakeryApi

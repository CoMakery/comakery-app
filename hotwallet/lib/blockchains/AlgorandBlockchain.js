const chainjs = require("@open-rights-exchange/chainjs")
const BigNumber = require('bignumber.js')
const HotWallet = require("../HotWallet").HotWallet

class AlgorandBlockchain {
  constructor(envs) {
    this.envs = envs
    this.blockchainNetwork = envs.blockchainNetwork
    const endpoints = this.endpointsByNetwork(this.blockchainNetwork)
    this.chain = new chainjs.ChainFactory().create(chainjs.ChainType.AlgorandV1, endpoints)
    // It is necessary to cache values gotten from blockchain
    this.optedInApps = {}
    this.algoBalances = {}
    this.tokenBalances = {}
  }

  mainnetEndpoints() {
    return [{
      url: 'https://mainnet-algorand.api.purestake.io/ps2',
      options: { indexerUrl: 'https://mainnet-algorand.api.purestake.io/idx2', headers: [{ 'x-api-key': this.envs.purestakeApi }] },
    }]
  }

  testnetEndpoints() {
    return [{
      url: 'https://testnet-algorand.api.purestake.io/ps2',
      options: { indexerUrl: 'https://testnet-algorand.api.purestake.io/idx2', headers: [{ 'x-api-key': this.envs.purestakeApi }] },
    }]
  }

  betanetEndpoints() {
    return [{
      url: 'https://betanet-algorand.api.purestake.io/ps2',
      options: { indexerUrl: 'https://betanet-algorand.api.purestake.io/idx2', headers: [{ 'x-api-key': this.envs.purestakeApi }] },
    }]
  }

  endpointsByNetwork(network) {
    switch (network) {
      case 'algorand_test':
        return this.testnetEndpoints()
      case 'algorand_beta':
        return this.betanetEndpoints()
      case 'algorand':
        return this.mainnetEndpoints()
      default:
        // added by oleg
        console.log("Unknown or unsupported network")
    }
  }

  createAccountOptions() {
    return {
      newKeysOptions: {
        password: 'hot_wallet_algorand_pwd',
        salt: 'hot_wallet_algorand_salt'
      }
    }
  }

  async connect() {
    if (!this.chain.isConnected) {
      await this.chain.connect()
    }
  }

  async generateNewWallet() {
    await this.connect()

    const createAccount = this.chain.new.CreateAccount(this.createAccountOptions())
    await createAccount.generateKeysIfNeeded()

    return new HotWallet(this.blockchainNetwork, createAccount.accountName, createAccount.generatedKeys)
  }

  async getAppLocalState(hotWalletAddress, appIndex) {
    await this.connect()

    try {
      const hwAccountDetails = await this.algoChain.algoClientIndexer.lookupAccountByID(hotWalletAddress).do()
      return hwAccountDetails.account['apps-local-state'].filter(app => !app.deleted && app.id === appIndex)[0]
    } catch (err) {
      return {}
    }
  }

  async getTokenBalance(hotWalletAddress) {
    if (hotWalletAddress in this.tokenBalances) { return this.tokenBalances[hotWalletAddress] }

    const localState = (await this.getAppLocalState(hotWalletAddress, this.envs.optInApp))
    const values = localState["key-value"]
    if (!values) { return 0 }

    const balanceValueArray = values.filter(val => val.key === "YmFsYW5jZQ==") // balance
    if (balanceValueArray.length === 0) { return 0 }

    const balanceValue = balanceValueArray[0].value.uint

    this.tokenBalances[hotWalletAddress] = balanceValue
    return balanceValue
  }

  async getOptedInAppsFromBlockchain(hotWalletAddress) {
    try {
      const hwAccountDetails = await this.algoChain.algoClientIndexer.lookupAccountByID(hotWalletAddress).do()
      return hwAccountDetails.account['apps-local-state'].filter(app => app.deleted == false).map(app => app.id)
    } catch (err) {
      return []
    }
  }

  async getOptedInAppsForHotWallet(hotWalletAddress) {
    if (hotWalletAddress in this.optedInApps) { return this.optedInApps[hotWalletAddress] }

    await this.connect()
    const optedInApps = await this.getOptedInAppsFromBlockchain(hotWalletAddress)
    if (optedInApps.length > 0) {
      this.optedInApps[hotWalletAddress] = optedInApps
    } else {
      console.log(`The Hot Wallet either has zero algos balance or doesn't opted-in to any app. Please send ALGOs to the wallet ${hotWalletAddress}`)
    }

    return optedInApps
  }

  async getAlgoBalanceForHotWallet(hotWalletAddress) {
    if (hotWalletAddress in this.algoBalances) { return this.algoBalances[hotWalletAddress] }

    await this.connect()
    const blockchainBalance = await this.algoChain.fetchBalance(hotWalletAddress, chainjs.HelpersAlgorand.toAlgorandSymbol('algo'))
    this.algoBalances[hotWalletAddress] = new BigNumber(blockchainBalance.balance)

    return this.algoBalances[hotWalletAddress]
  }

  async isOptedInToCurrentApp(hotWalletAddress) {
    const optedInApps = await this.getOptedInAppsForHotWallet(hotWalletAddress)
    return optedInApps.includes(this.envs.optInApp)
  }

  async enoughAlgoBalanceToSendTransaction(hotWalletAddress) {
    const algoBalance = await this.getAlgoBalanceForHotWallet(hotWalletAddress)
    return algoBalance.isGreaterThan(new BigNumber(0.001)) // 1000 microalgos
  }

  async positiveTokenBalance(hotWalletAddress) {
    const tokenBalance = await this.getTokenBalance(hotWalletAddress)
    return tokenBalance > 0
  }

  async optInToApp(hotWallet, appToOptIn) {
    await this.connect()

    const transaction = await this.algoChain.new.Transaction()
    const txn = {
      from: hotWallet.address,
      note: 'Opt-in from a HotWallet',
      appIndex: appToOptIn,
    }
    const action = await this.algoChain.composeAction(chainjs.ModelsAlgorand.AlgorandChainActionType.AppOptIn, txn)
    transaction.actions = [action]
    await transaction.prepareToBeSigned()
    await transaction.validate()
    await transaction.sign([chainjs.HelpersAlgorand.toAlgorandPrivateKey(hotWallet.secretKey())])

    try {
      const tx_result = await transaction.send(chainjs.Models.ConfirmType.After001)
      console.log(`Opt-in was successfully sent to blockchain, tx hash: ${tx_result.transactionId}`)
      return tx_result
    } catch (err) {
      // added by oleg
      console.log(err)
      return {}
    }
  }

  async isTransactionValid(transaction, hotWalletAddress) {
    if (typeof transaction !== 'string') { return { valid: false } }

    try {
      transaction = JSON.parse(transaction)

      // Is AppIndex for the current App?
      if (transaction.appIndex !== this.envs.optInApp) {
        const errorMessage = "The transaction is not for configured App."
        console.log(errorMessage)
        return { valid: false, markAs: "failed", error: errorMessage }
      }

      // Checks for transfer transaction
      if (transaction.appArgs[0] === "0x7472616e73666572") {
        const txTokensAmount = parseInt(transaction.appArgs[1])

        if (this.envs.maxAmountForTransfer > 0 && txTokensAmount > this.envs.maxAmountForTransfer) {
          const errorMessage = `The transaction has too big amount for transfer (${txTokensAmount}). Max amount is ${this.envs.maxAmountForTransfer}`
          console.log(errorMessage)
          return { valid: false, markAs: "failed", error: errorMessage }
        }

        const hwTokensBalance = await this.getTokenBalance(hotWalletAddress)
        if (hwTokensBalance < txTokensAmount) {
          const errorMessage = `The Hot Wallet has insufficient tokens to transfer (${hwTokensBalance} < ${txTokensAmount})`
          console.log(errorMessage)
          return { valid: false, markAs: "cancelled", error: errorMessage }
        }
      }
      return { valid: true }
    } catch (err) {
      return { valid: false, markAs: "failed", error: `Unknown error: ${err}` }
    }
  }
}
exports.AlgorandBlockchain = AlgorandBlockchain

const { promisify } = require("util")
const algosdk = require("algosdk")
const chainjs = require("@open-rights-exchange/chainjs")
const axios = require("axios")

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

class HotWalletRedis {
  constructor(envs, redisClient) {
    this.envs = envs
    this.client = redisClient

    // Set error handler
    this.client.on("error", function (err) {
      console.error(`Redis client error: ${err}`);
    })
  }

  walletKeyName() {
    return `wallet_for_project_${this.envs.projectId}`
  }

  async hotWallet() {
    const savedHW = await this.hgetall(this.walletKeyName())

    if (savedHW) {
      const optedInApps = JSON.parse(savedHW.optedInApps || "[]")

      return new HotWallet(savedHW.address, savedHW.mnemonic, optedInApps)
    } else {
      return undefined
    }
  }

  async hotWalletAddress() {
    return await this.hget(this.walletKeyName(), "address")
  }

  async hotWalletMnenonic() {
    return await this.hget(this.walletKeyName(), "mnemonic")
  }

  async isHotWalletCreated() {
    return (await this.hotWallet()) !== undefined
  }

  async saveNewHotWallet(wallet) {
    await this.hset(this.walletKeyName(), "address", wallet.address, "mnemonic", wallet.mnemonic)
    console.log(`Keys for a new hot wallet has been saved into ${this.walletKeyName()}`)
    return true
  }

  async saveOptedInApps(optedInApps) {
    optedInApps = JSON.stringify(optedInApps)
    await this.hset(this.walletKeyName(), "optedInApps", optedInApps)
    console.log(`Opted-in apps (${optedInApps}) has been saved into ${this.walletKeyName()}`)
    return true
  }

  async deleteCurrentKey() {
    await this.del(this.walletKeyName())
    console.log(`Wallet keys has been deleted: ${this.walletKeyName()}`)
    return true
  }

  async hset(...args) {
    return await (promisify(this.client.hset).bind(this.client))(...args)
  }

  async hget(...args) {
    return await (promisify(this.client.hget).bind(this.client))(...args)
  }

  async hgetall(...args) {
    return await (promisify(this.client.hgetall).bind(this.client))(...args)
  }

  async del(...args) {
    return await (promisify(this.client.del).bind(this.client))(...args)
  }
}
exports.HotWalletRedis = HotWalletRedis

class AlgorandBlockchain {
  constructor(envs) {
    this.envs = envs
    this.blockchainNetwork = envs.blockchainNetwork
    const endpoints = this.endpointsByNetwork(this.blockchainNetwork)
    this.algoChain = new chainjs.ChainFactory().create(chainjs.ChainType.AlgorandV1, endpoints)
    // It is necessary to cache values gotten from blockchain
    this.optedInApps = {}
    this.balances = {}
  }

  algoMainnetEndpoints() {
    return [{
      url: 'https://mainnet-algorand.api.purestake.io/ps2',
      options: { indexerUrl: 'https://mainnet-algorand.api.purestake.io/idx2', headers: [{ 'x-api-key': this.envs.purestakeApi }] },
    }]
  }

  algoTestnetEndpoints() {
    return [{
      url: 'https://testnet-algorand.api.purestake.io/ps2',
      options: { indexerUrl: 'https://testnet-algorand.api.purestake.io/idx2', headers: [{ 'x-api-key': this.envs.purestakeApi }] },
    }]
  }

  algoBetanetEndpoints() {
    return [{
      url: 'https://betanet-algorand.api.purestake.io/ps2',
      options: { indexerUrl: 'https://betanet-algorand.api.purestake.io/idx2', headers: [{ 'x-api-key': this.envs.purestakeApi }] },
    }]
  }

  endpointsByNetwork(network) {
    switch (network) {
      case 'algorand_test':
        return this.algoTestnetEndpoints()
      case 'algorand_beta':
        return this.algoBetanetEndpoints()
      case 'algorand':
        return this.algoMainnetEndpoints()
      default:
        console.error("Unknown or unsupported network")
    }
  }

  generateAlgorandKeyPair() {
    const account = algosdk.generateAccount()
    const mnemonic = algosdk.secretKeyToMnemonic(account.sk);

    return new HotWallet(account.addr, mnemonic)
  }

  async connect() {
    if (!this.algoChain.isConnected) {
      await this.algoChain.connect()
    }
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

  async getBalanceForHotWallet(hotWalletAddress) {
    if (hotWalletAddress in this.balances) { return this.balances[hotWalletAddress] }

    await this.connect()
    const blockchainBalance = await this.algoChain.fetchBalance(hotWalletAddress, chainjs.HelpersAlgorand.toAlgorandSymbol('algo'))
    this.balances[hotWalletAddress] = parseFloat(blockchainBalance.balance)
    return this.balances[hotWalletAddress]
  }

  async isOptedInToCurrentApp(hotWalletAddress) {
    const optedInApps = await this.getOptedInAppsForHotWallet(hotWalletAddress)
    return optedInApps.includes(this.envs.optInApp)
  }

  async enoughBalanceToOptInForHotWallet(hotWalletAddress) {
    const balance = await this.getBalanceForHotWallet(hotWalletAddress)
    return balance > 0.1
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
      console.error(err)
      return {}
    }
  }
}
exports.AlgorandBlockchain = AlgorandBlockchain

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

  logError(functionName, error) {
    console.error(`${functionName} API call failed with:\n`)

    if (error.response) {
      console.error(
        `${error.response.status} (${error.response.statusText}) data:\n`,
        error.response.data
      )
    } else {
      console.error(error)
    }
  }
}
exports.ComakeryApi = ComakeryApi

exports.checkAllVariablesAreSet = function checkAllVariablesAreSet(envs) {
  return Boolean(envs.projectId) && Boolean(envs.projectApiKey) && Boolean(envs.comakeryServerUrl) &&
    Boolean(envs.purestakeApi) && Boolean(envs.redisUrl) && Boolean(envs.checkForNewTransactionsDelay) &&
    Boolean(envs.optInApp) && Boolean(envs.blockchainNetwork)
}

exports.isEmptyObject = function isEmptyObject(obj) {
  for (var prop in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, prop)) {
      return false
    }
  }
  return true
}

exports.sleep = function (ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

exports.hotWalletInitialization = async function hotWalletInitialization(envs, redisClient) {
  const walletRedis = new HotWalletRedis(envs, redisClient)
  const hwCreated = await walletRedis.isHotWalletCreated()

  if (hwCreated) {
    console.log("wallet already created, do nothing...")
  } else {
    console.log("Key file does not exists, generating...")
    const hwAlgorand = new AlgorandBlockchain(envs)
    const newWallet = hwAlgorand.generateAlgorandKeyPair()
    const hwApi = new ComakeryApi(envs)
    const registerRes = await hwApi.registerHotWallet(newWallet)

    if (registerRes && registerRes.status == 201) {
      const hwRedis = new HotWalletRedis(envs, redisClient)
      await hwRedis.saveNewHotWallet(newWallet)
    } else {
      return false
    }
  }
  return true
}

exports.runServer = async function runServer(envs, redisClient) {
  const hwRedis = new HotWalletRedis(envs, redisClient)

  while (true) {
    const hw = await hwRedis.hotWallet()
    const optedIn = await hw.isOptedInToApp(envs.optInApp)

    if (optedIn) {
      await exports.waitForNewTransaction(envs, hwRedis)
    } else {
      console.log("The Hot Wallet doesn't opted-in to the App. Trying to opt-in")
      await exports.autoOptIn(envs, hwRedis)
    }

    await exports.sleep(envs.checkForNewTransactionsDelay * 1000) // 30 seconds by default
  }
}

exports.waitForNewTransaction = async function waitForNewTransaction(envs, hwRedis) {
  console.log("Checking for a new transaction to send...")
  const hwApi = new ComakeryApi(envs)
  const hwAddress = await hwRedis.hotWalletAddress()
  const transactionToSign = await hwApi.getNextTransactionToSign(hwAddress)

  if (!exports.isEmptyObject(transactionToSign)) {
    console.log(`Found transaction to send, id=${transactionToSign.id}`)
    const tx = await exports.singAndSendTx(transactionToSign, envs, hwRedis)
    if (!exports.isEmptyObject(tx)) {
      const hwApi = new ComakeryApi(envs)
      transactionToSign.txHash = tx.transactionId
      await hwApi.updateTransactionHash(transactionToSign)
    } else {
      return false
    }
  } else {
    return false
  }
  return true
}

exports.singAndSendTx = async function singAndSendTx(transactionToSign, envs, hwRedis) {
  const hwAlgorand = new AlgorandBlockchain(envs)
  const mnemonic = await hwRedis.hotWalletMnenonic()

  const endpoints = hwAlgorand.endpointsByNetwork(transactionToSign.network)
  const algoChain = new chainjs.ChainFactory().create(chainjs.ChainType.AlgorandV1, endpoints)
  const { sk } = algosdk.mnemonicToSecretKey(mnemonic)

  await algoChain.connect()
  const transaction = await algoChain.new.Transaction()
  const txn = JSON.parse(transactionToSign.txRaw || "{}")
  const action = await algoChain.composeAction(chainjs.ModelsAlgorand.AlgorandChainActionType.AppNoOp, txn)
  transaction.actions = [action]
  await transaction.prepareToBeSigned()
  await transaction.validate()
  await transaction.sign([chainjs.HelpersAlgorand.toAlgorandPrivateKey(sk)])

  try {
    const tx_result = await transaction.send(chainjs.Models.ConfirmType.After001)
    console.log(`Transaction has successfully signed and sent to blockchain tx hash: ${tx_result.transactionId}`)
    return tx_result
  } catch (err) {
    console.error(err)
    return {}
  }
}

exports.autoOptIn = async function autoOptIn(envs, hwRedis) {
  const hw = await hwRedis.hotWallet()

  // Already opted-in and we already know about it
  if (hw.isOptedInToApp(envs.optInApp)) {
    console.log("HW opted-in. Cached in Redis")
    return hw.optedInApps
  }

  const hwAlgorand = new AlgorandBlockchain(envs)
  // Check if already opted-in on blockchain
  if (await hwAlgorand.isOptedInToCurrentApp(hw.address)) {
    console.log("HW opted-in. Got from Blockchain")

    // Save it in Redis and return
    const optedInApps = await hwAlgorand.getOptedInAppsForHotWallet(hw.address)
    await hwRedis.saveOptedInApps(optedInApps)
    return optedInApps
  }

  // Check if the wallet has enough balance to send opt-in transaction
  if (await hwAlgorand.enoughBalanceToOptInForHotWallet(hw.address)) {
    tx_result = await hwAlgorand.optInToApp(hw, envs.optInApp)
    if (exports.isEmptyObject(tx_result)) {
      console.log(`Failed to opt-in into app ${envs.optInApp} for wallet ${hw.address}`)
    } else {
      console.log("HW successfully opted-in!")

      // Successfully opted-in
      const optedInApps = await hwAlgorand.getOptedInAppsForHotWallet(hw.address)
      await hwRedis.saveOptedInApps(optedInApps)
      return optedInApps
    }
  }
}

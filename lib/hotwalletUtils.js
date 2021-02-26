const { promisify } = require("util")
const algosdk = require("algosdk")
const chainjs = require("@open-rights-exchange/chainjs")
const axios = require("axios")

class HotWallet {
  constructor(address, mnemonic, optedInApps) {
    this.address = address
    this.mnemonic = mnemonic
    this.optedInApps = optedInApps
  }

  isOptedInToApp(appIndexToCheck) {
    if (!this.optedInApps) { return false }
    return this.optedInApps.includes(appIndexToCheck)
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
      console.error(`registerHotWallet call failed with ${error.response.status} (${error.response.statusText}) data:`)
      console.error(error.response.data)
      return false
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
      console.error(`getNextTransactionToSign call failed with ${error.response.status} (${error.response.statusText}) data:`)
      console.error(error.response.data)
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
      console.error(`updateTransactionHash call failed with ${error.response.status} (${error.response.statusText}) data:`)
      console.error(error.response.data)
      return {}
    }
  }
}
exports.ComakeryApi = ComakeryApi

exports.checkAllVariablesAreSet = function checkAllVariablesAreSet(envs) {
  return Boolean(envs.projectId) && Boolean(envs.projectApiKey) && Boolean(envs.comakeryServerUrl) &&
    Boolean(envs.purestakeApi) && Boolean(envs.redisUrl) && Boolean(envs.checkForNewTransactionsDelay) &&
    Boolean(envs.optInApp)
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
    }
  }
  return true
}

exports.runServer = async function runServer(envs, redisClient) {
  while (true) {
    await exports.waitForNewTransaction(envs, redisClient)

    await exports.sleep(envs.checkForNewTransactionsDelay * 1000) // 30 seconds by default
  }
}

exports.waitForNewTransaction = async function waitForNewTransaction(envs, redisClient) {
  console.log("Checking for a new transaction to send...")
  const hwRedis = new HotWalletRedis(envs, redisClient)
  const hwApi = new ComakeryApi(envs)
  const hwAddress = await hwRedis.hotWalletAddress()
  const transactionToSign = await hwApi.getNextTransactionToSign(hwAddress)

  if (!exports.isEmptyObject(transactionToSign)) {
    console.log(`Found transaction to send, id=${transactionToSign.id}`)
    const tx = await exports.singAndSendTx(transactionToSign, envs, redisClient)
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

exports.singAndSendTx = async function singAndSendTx(transactionToSign, envs, redisClient) {
  const hwRedis = new HotWalletRedis(envs, redisClient)
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

exports.optInToApp = async function optInToApp(network, appIndex, envs, redisClient) {
  const hwRedis = new HotWalletRedis(envs, redisClient)
  const hwAlgorand = new AlgorandBlockchain(envs)
  const mnemonic = await hwRedis.hotWalletMnenonic()
  const endpoints = hwAlgorand.endpointsByNetwork(network)

  const algoChain = new chainjs.ChainFactory().create(chainjs.ChainType.AlgorandV1, endpoints)
  const { addr, sk } = algosdk.mnemonicToSecretKey(mnemonic)
  await algoChain.connect()
  if (algoChain.isConnected) { console.log(`Connected to ${algoChain.chainId}`) }
  const transaction = await algoChain.new.Transaction()
  const txn = {
    from: addr,
    note: 'test optIn',
    appIndex: appIndex,
  }
  const action = await algoChain.composeAction(chainjs.ModelsAlgorand.AlgorandChainActionType.AppOptIn, txn)
  transaction.actions = [action]
  await transaction.prepareToBeSigned()
  await transaction.validate()
  await transaction.sign([chainjs.HelpersAlgorand.toAlgorandPrivateKey(sk)])

  try {
    const tx_result = await transaction.send(chainjs.Models.ConfirmType.After001)
    console.log(`Opt-in was successfully sent to blockchain, tx hash: ${tx_result.transactionId}`)
    return tx_result
  } catch (err) {
    console.error(err)
    return {}
  }
}

exports.autoOptIn = async function autoOptIn(envs, redisClient) {
  const walletRedis = new HotWalletRedis(envs, redisClient)
  const hw = await walletRedis.hotWallet()
  // Already opted-in
  if (hw.isOptedInToApp(envs.optInApp)) { return hw.optedInApps }

  // TODO:
  // 1. Check if it already opted in on blockchain, add to "optedInApps" if exists
  // 2. Check if the wallet has enough balance to send opt-in transaction. If so send the transaction and add to "optedInApps"

  const network = 'algorand_test' // TODO: Extract it to ENV
  const hwAlgorand = new AlgorandBlockchain(envs)
  const endpoints = hwAlgorand.endpointsByNetwork(network)
  const algoChain = new chainjs.ChainFactory().create(chainjs.ChainType.AlgorandV1, endpoints)
  await algoChain.connect()

  const balance = await algoChain.fetchBalance(hw.address, chainjs.HelpersAlgorand.toAlgorandSymbol('algo'))
  console.log(balance)
}

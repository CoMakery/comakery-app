const { promisify } = require("util")
const algosdk = require("algosdk")
const chainjs = require("@open-rights-exchange/chainjs")
const axios = require("axios")

class HotWallet {
  constructor(address, mnemonic) {
    this.address = address
    this.mnemonic = mnemonic
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
      return new HotWallet(savedHW.address, savedHW.mnemonic)
    } else {
      return undefined
    }
  }

  async isHotWalletCreated() {
    return (await this.hotWallet()) !== undefined
  }

  async saveNewHotWallet(wallet) {
    await this.hset(this.walletKeyName(), "address", wallet.address, "mnemonic", wallet.mnemonic)
    console.log(`Keys for a new hot wallet has been saved into ${this.walletKeyName()}`)
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
}

exports.HotWalletRedis = HotWalletRedis

exports.keyName = function keyName(projectId) {
  return `wallet_for_project_${projectId}`
}

exports.algoMainnetEndpoints = function algoMainnetEndpoints(purestakeApi) {
  return [{
    url: 'https://mainnet-algorand.api.purestake.io/ps2',
    options: { indexerUrl: 'https://mainnet-algorand.api.purestake.io/idx2', headers: [{ 'x-api-key': purestakeApi }] },
  }]
}

exports.algoTestnetEndpoints = function algoTestnetEndpoints(purestakeApi) {
  return [{
    url: 'https://testnet-algorand.api.purestake.io/ps2',
    options: { indexerUrl: 'https://testnet-algorand.api.purestake.io/idx2', headers: [{ 'x-api-key': purestakeApi }] },
  }]
}

exports.algoBetanetEndpoints = function algoBetanetEndpoints(purestakeApi) {
  return [{
    url: 'https://betanet-algorand.api.purestake.io/ps2',
    options: { indexerUrl: 'https://betanet-algorand.api.purestake.io/idx2', headers: [{ 'x-api-key': purestakeApi }] },
  }]
}

exports.endpointsByNetwork = function endpointsByNetwork(network, envs) {
  switch (network) {
    case 'algorand_test':
      return exports.algoTestnetEndpoints(envs.purestakeApi)
    case 'algorand_beta':
      return exports.algoBetanetEndpoints(envs.purestakeApi)
    case 'algorand':
      return exports.algoMainnetEndpoints(envs.purestakeApi)
    default:
      console.error("Unknown or unsupported network")
  }
}

exports.checkAllVariablesAreSet = function checkAllVariablesAreSet(envs) {
  return Boolean(envs.projectId) && Boolean(envs.projectApiKey) && Boolean(envs.comakeryServerUrl) &&
    Boolean(envs.purestakeApi) && Boolean(envs.redisUrl) && Boolean(envs.checkForNewTransactionsDelay)
}

exports.isEmptyObject = function isEmptyObject(obj) {
  for(var prop in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, prop)) {
      return false
    }
  }
  return true
}

exports.sleep = function (ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

exports.setRedisErrorHandler = function setRedisErrorHandler(redisClient) {
  redisClient.on("error", function (err) {
    console.error(`Redis client error: ${err}`);
  })
}

exports.generateAlgorandKeyPair = function generateAlgorandKeyPair() {
  const account = algosdk.generateAccount()
  const mnemonic = algosdk.secretKeyToMnemonic(account.sk);

  return new HotWallet(account.addr, mnemonic)
}

exports.registerHotWallet = async function registerHotWallet(wallet, envs, redisClient) {
  const registerHotWalletUrl = `${envs.comakeryServerUrl}/api/v1/projects/${envs.projectId}/hot_wallet_addresses`
  const params = { body: { data: { hot_wallet: { address: wallet.address } } } }
  const config = { headers: { "API-Transaction-Key": envs.projectApiKey } }

  try {
    const res = await axios.post(registerHotWalletUrl, params, config)

    if (res.status == 201) {
      const hwRedis = new HotWalletRedis(envs, redisClient)
      await hwRedis.saveNewHotWallet(wallet)
    }

    return true
  } catch (error) {
    console.error(`registerHotWallet call failed with ${error.response.status} (${error.response.statusText}) data:`)
    console.error(error.response.data)
    return false
  }
}

exports.hotWalletInitialization = async function hotWalletInitialization(envs, redisClient) {
  const walletRedis = new HotWalletRedis(envs, redisClient)
  const hwCreated = await walletRedis.isHotWalletCreated()

  if (hwCreated) {
    console.log("wallet already created, do nothing...")
  } else {
    console.log("Key file does not exists, generating...")
    const newWallet = exports.generateAlgorandKeyPair()
    await exports.registerHotWallet(newWallet, envs, redisClient)
  }
  return true
}

exports.deleteCurrentKey = async function deleteCurrentKey(envs, redisClient) {
  const keyName = exports.keyName(envs.projectId)
  const deleteKey = promisify(redisClient.del).bind(redisClient)
  await deleteKey(keyName)
  console.log(`Wallet keys has been deleted: ${keyName}`)
}

exports.runServer = async function runServer(envs, redisClient) {
  while (true) {
    // if (optedIn) {
    await exports.waitForNewTransaction(envs, redisClient)
    // } else {
    // await exports.tryToOptIn(envs,redisClient)
    // }

    await exports.sleep(envs.checkForNewTransactionsDelay * 1000) // 30 seconds by default
  }
}

exports.waitForNewTransaction = async function waitForNewTransaction(envs, redisClient) {
  console.log("Checking for a new transaction to send...")

  const hget = promisify(redisClient.hget).bind(redisClient)
  let hwAddress
  await hget(exports.keyName(envs.projectId), "address").then(function (res) { hwAddress = res })

  const transactionToSign = await exports.getNextTransactionToSignFromAPI(hwAddress, envs)

  if (!exports.isEmptyObject(transactionToSign)) {
    console.log(`Found transaction to send, id=${transactionToSign.id}`)
    const tx = await exports.singAndSendTx(transactionToSign, envs, redisClient)
    if (!exports.isEmptyObject(tx)) {
      transactionToSign.txHash = tx.transactionId
      await exports.updateTransactionHash(transactionToSign, envs)
    } else {
      return false
    }
  } else {
    return false
  }
  return true
}

exports.singAndSendTx = async function singAndSendTx(transactionToSign, envs, redisClient) {
  const hget = promisify(redisClient.hget).bind(redisClient)
  let mnemonic
  await hget(exports.keyName(envs.projectId), "mnemonic").then(function (res) { mnemonic = res })

  const endpoints = exports.endpointsByNetwork(transactionToSign.network, envs)
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
  const hget = promisify(redisClient.hget).bind(redisClient)
  let mnemonic
  await hget(exports.keyName(envs.projectId), "mnemonic").then(function (res) { mnemonic = res })

  const endpoints = exports.endpointsByNetwork(network, envs)
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

exports.getNextTransactionToSignFromAPI = async function getNextTransactionToSignFromAPI(hwAddress, envs) {
  const blockchainTransactionsUrl = `${envs.comakeryServerUrl}/api/v1/projects/${envs.projectId}/blockchain_transactions`
  const params = { body: { data: { transaction: { source: hwAddress } } } }
  const config = { headers: { "API-Transaction-Key": envs.projectApiKey } }

  try {
    const res = await axios.post(blockchainTransactionsUrl, params, config)
    if (res.status == 201) {
      return res.data
    } else {
      return {}
    }
  } catch (error) {
    console.error(`getNextTransactionToSignFromAPI call failed with ${error.response.status} (${error.response.statusText}) data:`)
    console.error(error.response.data)
    return {}
  }
}

exports.updateTransactionHash = async function updateTransactionHash(blockchainTransaction, envs) {
  const blockchainTransactionsUrl = `${envs.comakeryServerUrl}/api/v1/projects/${envs.projectId}/blockchain_transactions/${blockchainTransaction.id}`
  const params = { body: { data: { transaction: { tx_hash: blockchainTransaction.txHash } } } }
  const config = { headers: { "API-Transaction-Key": envs.projectApiKey } }

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

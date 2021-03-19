const algosdk = require("algosdk")
const chainjs = require("@open-rights-exchange/chainjs")

// Custom classes
const HotWallet = require("./HotWallet").HotWallet
exports.HotWallet = HotWallet
const HotWalletRedis = require("./HotWalletRedis").HotWalletRedis
exports.HotWalletRedis = HotWalletRedis
const AlgorandBlockchain = require("./blockchains/AlgorandBlockchain").AlgorandBlockchain
exports.AlgorandBlockchain = AlgorandBlockchain
const ComakeryApi = require("./ComakeryApi").ComakeryApi
exports.ComakeryApi = ComakeryApi

exports.checkAllVariablesAreSet = function checkAllVariablesAreSet(envs) {
  return Boolean(envs.projectId) && Boolean(envs.projectApiKey) && Boolean(envs.comakeryServerUrl) &&
    Boolean(envs.purestakeApi) && Boolean(envs.redisUrl) && Boolean(envs.checkForNewTransactionsDelay) &&
    Boolean(envs.optInApp) && Boolean(envs.blockchainNetwork) && Boolean(envs.maxAmountForTransfer)
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
  const hwAddress = await hwRedis.hotWalletAddress()
  const hwAlgorand = new AlgorandBlockchain(envs)

  const enoughAlgos = await hwAlgorand.enoughAlgoBalanceToSendTransaction(hwAddress)
  if (!enoughAlgos) {
    console.log(`The Hot Wallet does not have enough balance of ALGOs to send transactions. Please top up the ${hwAddress}`)
    return false
  }

  const hasTokens = await hwAlgorand.positiveTokenBalance(hwAddress)
  if (!hasTokens) {
    console.log(`The Hot Wallet does not have NOTE tokens. Please top up the ${hwAddress}`)
    return false
  }

  console.log(`Checking for a new transaction to send from ${hwAddress}`)
  const hwApi = new ComakeryApi(envs)
  const transactionToSign = await hwApi.getNextTransactionToSign(hwAddress)
  const txValidation = await hwAlgorand.isTransactionValid(transactionToSign.txRaw, hwAddress)

  if (txValidation.valid) {
    console.log(`Found transaction to send, id=${transactionToSign.id}`)
    const tx = await exports.signAndSendTx(transactionToSign, envs, hwRedis)
    if (!exports.isEmptyObject(tx)) {
      transactionToSign.txHash = tx.transactionId
      await hwApi.updateTransactionHash(transactionToSign)
    } else {
      return false
    }
  } else { // tx is invalid
    if (txValidation.markAs) {
      await hwApi.cancelTransaction(transactionToSign, txValidation.error, txValidation.markAs)
    }
    return false
  }
  return true
}

exports.signAndSendTx = async function signAndSendTx(transactionToSign, envs, hwRedis) {
  const hwAlgorand = new AlgorandBlockchain(envs)
  const mnemonic = await hwRedis.hotWalletMnenonic()
  const endpoints = hwAlgorand.endpointsByNetwork(transactionToSign.network)
  const algoChain = new chainjs.ChainFactory().create(chainjs.ChainType.AlgorandV1, endpoints)
  const { addr, sk } = algosdk.mnemonicToSecretKey(mnemonic)

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
    console.log(`Transaction has successfully signed and sent by ${addr} to blockchain tx hash: ${tx_result.transactionId}`)
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
  if (await hwAlgorand.enoughAlgoBalanceToSendTransaction(hw.address)) {
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

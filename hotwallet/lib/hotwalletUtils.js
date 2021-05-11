const algosdk = require("algosdk")
const chainjs = require("@open-rights-exchange/chainjs")

// Custom classes
const HotWallet = require("./HotWallet").HotWallet
exports.HotWallet = HotWallet
const HotWalletRedis = require("./HotWalletRedis").HotWalletRedis
exports.HotWalletRedis = HotWalletRedis
const Blockchain = require("./Blockchain").Blockchain
exports.Blockchain = Blockchain
exports.AlgorandBlockchain = require("./Blockchain").AlgorandBlockchain
exports.EthereumBlockchain = require("./Blockchain").EthereumBlockchain
const ComakeryApi = require("./ComakeryApi").ComakeryApi
exports.ComakeryApi = ComakeryApi

exports.checkAllVariablesAreSet = function checkAllVariablesAreSet(envs) {
  return Boolean(envs.projectId) && Boolean(envs.projectApiKey) && Boolean(envs.comakeryServerUrl) &&
    Boolean(envs.infuraProjectId) && Boolean(envs.redisUrl) && Boolean(envs.emptyQueueDelay) &&
    Boolean(envs.blockchainNetwork) && Boolean(envs.ethereumTokenSymbol) && Boolean(envs.ethereumContractAddress)
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
    console.log("wallet already created, using it...")
  } else {
    console.log("Key file does not exists, generating...")
    const blockchain = new Blockchain(envs)
    const newWallet = await blockchain.generateNewWallet()
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

  try {
    while (true) {
      let delay = envs.emptyQueueDelay

      const resTx = await exports.waitForNewTransaction(envs, hwRedis)

      if (["cancelled_transaction", "successfull"].indexOf(resTx.status) > -1) {
        delay = envs.betweenTransactionDelay
      }

      console.log(`waiting ${delay} seconds`)
      await exports.sleep(delay * 1000)
    }
  } catch (err) {
    console.error(err)
    process.exit(1) // kill the process to make pm2 restart
  }

}

exports.waitForNewTransaction = async function waitForNewTransaction(envs, hwRedis) {
  const hotWallet = await hwRedis.hotWallet()
  const hwAddress = await hotWallet.address
  const blockchain = new Blockchain(envs)

  const enoughCoins = await blockchain.enoughCoinBalanceToSendTransaction(hwAddress)
  if (!enoughCoins) {
    console.log(`The Hot Wallet does not have enough balance to send transactions. Please top up the ${hwAddress}`)
    return { status: "failed_before_getting_tx", blockchainTransaction: {}, transaction: {} }
  }

  const isReadyToSendTx = hotWallet.isReadyToSendTx(envs)
  if (!isReadyToSendTx) {
    if (hotWallet.isEthereum() && envs.ethereumContractAddress && envs.ethereumBatchContractAddress) {
      const approveTx = await blockchain.klass.approveBatchContractTransactions(hotWallet, envs.ethereumContractAddress, envs.ethereumBatchContractAddress)
      if (approveTx.transactionId) {
        hwRedis.saveApprovedBatchContract(envs.ethereumBatchContractAddress)
      }
    }
  }

  const hasTokens = await blockchain.positiveTokenBalance(hwAddress)
  if (!hasTokens) {
    console.log(`The Hot Wallet does not have tokens. Please top up the ${hwAddress}`)
    return { status: "failed_before_getting_tx", blockchainTransaction: {}, transaction: {} }
  }

  console.log(`Checking for a new transaction to send from ${hwAddress}`)
  const hwApi = new ComakeryApi(envs)
  const blockchainTransaction = await hwApi.getNextTransactionToSign(hwAddress)
  const txValidation = await blockchain.isTransactionValid(blockchainTransaction.txRaw, hwAddress)

  if (txValidation.valid) {
    const prevTx = await hwRedis.getSavedDataForTransaction(blockchainTransaction)

    if (prevTx) {
      const errorMessage = `The Hot Wallet already sent transaction at least for ${prevTx.key}, details: ${JSON.stringify(prevTx.values)}`
      console.log(errorMessage)
      await hwApi.cancelTransaction(blockchainTransaction, errorMessage, "failed")
      return { status: "tx_already_sent", blockchainTransaction: blockchainTransaction, transaction: {} }
    }

    console.log(`Found transaction to send, id=${blockchainTransaction.id}`)
    const tx = await blockchain.sendTransaction(blockchainTransaction, hotWallet, blockchain)

    if (typeof tx.valid == 'undefined' || tx.valid) {
      // tx successfully sent
      blockchainTransaction.txHash = tx.transactionId

      if (blockchainTransaction.blockchainTransactableId && blockchainTransaction.blockchainTransactableType) {
        await hwRedis.saveDavaForTransaction("successfull", blockchainTransaction.blockchainTransactableType, blockchainTransaction.blockchainTransactableId, blockchainTransaction.txHash)
      } else if (Array.isArray(blockchainTransaction.blockchainTransactables) && blockchainTransaction.blockchainTransactables.length > 0) {
        blockchainTransaction.blockchainTransactables.forEach(async (bt) => {
          await hwRedis.saveDavaForTransaction("successfull", bt.blockchainTransactableType, bt.blockchainTransactableId, blockchainTransaction.txHash)
        })
      }

      await hwApi.updateTransactionHash(blockchainTransaction)
      return { status: "successfull", blockchainTransaction: blockchainTransaction, transaction: tx }
    } else {
      // tx failed during sending
      if (tx.markAs) {
        await hwApi.cancelTransaction(blockchainTransaction, tx.error, tx.markAs)
      }
      return { status: "cancelled_transaction", blockchainTransaction: blockchainTransaction, transaction: tx }
    }
  } else { // tx is invalid
    if (txValidation.markAs) {
      await hwApi.cancelTransaction(blockchainTransaction, txValidation.error, txValidation.markAs)
    }
    return { status: "validation_failed", blockchainTransaction: blockchainTransaction, transaction: {} }
  }
}

// TODO: Remove me. It's legacy and will not use anymore
exports.signAndSendTx = async function signAndSendTx(transactionToSign, envs, hwRedis) {
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

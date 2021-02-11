const { promisify } = require("util")
const algosdk = require('algosdk')
const axios = require('axios')

exports.keyName = function keyName(projectId) {
  return `wallet_for_project_${projectId}`
}

exports.checkAllVariablesAreSet = function checkAllVariablesAreSet(envs) {
  return Boolean(envs.projectId) && Boolean(envs.projectApiKey) && Boolean(envs.comakeryServerUrl) &&
    Boolean(envs.purestakeApi) && Boolean(envs.redisUrl)
}

exports.setRedisErrorHandler = function setRedisErrorHandler(redisClient) {
  redisClient.on("error", function (err) {
    console.error(`Redis client error: ${err}`);
  })
}

exports.generateAlgorandKeyPair = function generateAlgorandKeyPair() {
  const account = algosdk.generateAccount()
  const mnemonic = algosdk.secretKeyToMnemonic(account.sk);
  const new_wallet = { address: account.addr, mnemonic: mnemonic }

  return new_wallet
}

exports.storeHotWalletKeys = async function storeHotWalletKeys(wallet, envs, redisClient) {
  const keyName = exports.keyName(envs.projectId)
  const writeKeys = promisify(redisClient.hset).bind(redisClient)
  await writeKeys(keyName, "address", wallet.address, "mnemonic", wallet.mnemonic)
    .catch(function (error) {
      console.error(`Can't set a wallet key: ${error}`)
    })
  console.log(`Keys for a new hot wallet has been saved into ${keyName}`)
  return true
}

exports.registerHotWallet = async function registerHotWallet(wallet, envs, redisClient) {
  const registerHotWalletUrl = `${envs.comakeryServerUrl}/api/v1/projects/${envs.projectId}/hot_wallet_addresses`
  const params = { body: { data: { hot_wallet: { address: wallet.address } } } }
  const config = { headers: { "API-Transaction-Key": envs.projectApiKey } }

  try {
    const res = await axios.post(registerHotWalletUrl, params, config)

    if (res.status == 201) {
      await exports.storeHotWalletKeys(wallet, envs, redisClient)
    }
    return true
  } catch (error) {
    console.error(`registerHotWallet call failed with ${error.response.status} (${error.response.statusText}) data:`)
    console.error(error.response.data)
    return false
  }
}

exports.hotWalletInitialization = async function hotWalletInitialization(envs, redisClient) {
  const keyName = exports.keyName(envs.projectId)
  const getWalletKeys = promisify(redisClient.hgetall).bind(redisClient)

  await getWalletKeys(keyName)
    .then(function (walletKeys) {
      if (walletKeys) {
        console.log("wallet already created, do nothing...")
      } else {
        console.log("Key file does not exists, generating...")
        const newWallet = exports.generateAlgorandKeyPair()
        exports.registerHotWallet(newWallet, envs, redisClient)
      }
    }).catch(function (err) {
      console.error("Can't get a wallet keys: " + err)
    })
  return true
}

exports.deleteCurrentKey = async function deleteCurrentKey(envs, redisClient) {
  const keyName = exports.keyName(envs.projectId)
  const deleteKey = promisify(redisClient.del).bind(redisClient)
  await deleteKey(keyName)
  console.log(`Wallet keys has been deleted: ${keyName}`)
}

exports.sleep = function (ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

exports.runServer = async function runServer(envs, redisClient) {
  while(true) {
    exports.waitForNewTransaction(envs, redisClient)
    exports.signNextTransaction(envs, redisClient)
    await exports.sleep(10000) // 10 second
  }
}

exports.waitForNewTransaction = async function waitForNewTransaction(envs, redisClient) {
  console.log("waitForNewTransaction tick")
  const transactionToSign = await exports.getNextTransactionToSignFromAPI(envs)

  if (!exports.isEmptyObject(transactionToSign)) {
    // await exports.addTransactionToSignQueue(transactionToSign, redisClient)
    // console.log(`BlockchainTransaction id=${transactionToSign.id} has added to the queue to sign`)
    transactionToSign.txRaw
  }
}

exports.signNextTransaction = async function signNextTransaction(envs, redisClient) {
  console.log("signNextTransaction tick")
  const txToSign = await exports.getNextTransactionToSign(redisClient)
  console.log(txToSign)
}

exports.getNextTransactionToSignFromAPI = async function getNextTransactionToSignFromAPI(envs) {
  const blockchainTransactionsUrl = `${envs.comakeryServerUrl}/api/v1/projects/${envs.projectId}/blockchain_transactions`
  const params = { body: { data: { transaction: { source: "WDD3X6B4WFQDCH5N345I4F47LP5KCBI7YCDWFPJ2NO3YBNGQXBMYXT7T7U" } } } }
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

exports.addTransactionToSignQueue = async function addTransactionToSignQueue(transactionToSign, redisClient) {
  const hset = promisify(redisClient.hset).bind(redisClient)
  const sadd = promisify(redisClient.sadd).bind(redisClient)
  const txId = transactionToSign.id

  hset(`bt_${txId}`,
    "id", String(txId),
    "destination", String(transactionToSign.destination),
    "source", String(transactionToSign.source),
    "amount", String(transactionToSign.amount),
    "contractAddress", String(transactionToSign.contractAddress),
    "network", String(transactionToSign.network),
    "txHash", String(transactionToSign.txHash),
    "txRaw", String(transactionToSign.txRaw),
    "status", String(transactionToSign.status)
  ).catch(function (error) {
    console.error(`Can't save bt_${txId}:`)
    console.error(error)
  })
  sadd("bt_ids_to_sign", txId).catch(function (error) {
    console.error(`Can't save bt_ids_to_sign:`)
    console.error(error)
  })
}

exports.isEmptyObject = function isEmptyObject(obj) {
  for(var prop in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, prop)) {
      return false;
    }
  }
  return true;
}

exports.getNextTransactionToSign = async function getNextTransactionToSign(redisClient) {
  const spop = promisify(redisClient.spop).bind(redisClient)
  const hgetall = promisify(redisClient.hgetall).bind(redisClient)

  const txId = await spop("bt_ids_to_sign").catch(function (error) {
    console.error(`Can't get next value from bt_ids_to_sign:`)
    console.error(error)
  })
  const nextTxToSign = await hgetall(`bt_${txId}`)
  return nextTxToSign
}

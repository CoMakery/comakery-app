const { promisify } = require("util")
const algosdk = require('algosdk')
const chainjs = require("@open-rights-exchange/chainjs")
const axios = require('axios')

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

exports.checkAllVariablesAreSet = function checkAllVariablesAreSet(envs) {
  return Boolean(envs.projectId) && Boolean(envs.projectApiKey) && Boolean(envs.comakeryServerUrl) &&
    Boolean(envs.purestakeApi) && Boolean(envs.redisUrl)
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

exports.runServer = async function runServer(envs, redisClient) {
  while (true) {
    await exports.waitForNewTransaction(envs, redisClient)
    // await exports.sleep(10000) // 10 second
  }
}

exports.waitForNewTransaction = async function waitForNewTransaction(envs, redisClient) {
  console.log("waitForNewTransaction tick")
  const transactionToSign = await exports.getNextTransactionToSignFromAPI(envs)

  if (!exports.isEmptyObject(transactionToSign)) {
    await exports.singAndSendTx(transactionToSign, envs)
  }
}

exports.singAndSendTx = async function singAndSendTx(transactionToSign, envs) {
  const mnemonic = "turtle basic force reject inspire orchard believe lucky remain true purpose pulse museum school salt flame addict fortune solar brand giggle material bomb absent grab"
  const algoChain = new chainjs.ChainFactory().create(chainjs.ChainType.AlgorandV1, exports.algoTestnetEndpoints(envs.purestakeApi))
  const { addr, sk } = algosdk.mnemonicToSecretKey(mnemonic)

  await algoChain.connect()
  if (algoChain.isConnected) { console.log(`Connected to ${algoChain.chainId}`) }
  const transaction = await algoChain.new.Transaction()
  // TODO: Fill txn from transactionToSign.tx_raw
  const txn = {
    type: "appl",
    from: addr,
    appIndex: 13997710,
    appOnComplete: 0,
    appArgs: ["dHJhbnNmZXI=", new Uint8Array([15])],
    appAccounts: ["6447K33DMECECFTWCWQ6SDJLY7EYM47G4RC5RCOKPTX5KA5RCJOTLAK7LU"]
  }
  const action = await algoChain.composeAction(chainjs.ModelsAlgorand.AlgorandChainActionType.AppNoOp, txn)
  transaction.actions = [action]
  await transaction.prepareToBeSigned()
  await transaction.validate()
  await transaction.sign([chainjs.HelpersAlgorand.toAlgorandPrivateKey(sk)])

  try {
    console.log('send response: %o', JSON.stringify(await transaction.send(chainjs.Models.ConfirmType.After001)))
    // TODO: Send update request to blockchain transaction to update tx_hash with hash of the sent transaction.
  } catch (err) {
    console.error(err)
  }
}

// Successfull response:
// '{"transactionId":"VQSZLDQVOLBU65W4UWFDWBGMZHGU5KVKNCPL6P3GQ7W6DOJRTEWQ","chainResponse":{"application-transaction":{"accounts":[],"application-args":[],"application-id":13997710,"foreign-apps":[],"foreign-assets":[],"global-state-schema":{"num-byte-slice":0,"num-uint":0},"local-state-schema":{"num-byte-slice":0,"num-uint":0},"on-completion":"optin"},"close-rewards":0,"closing-amount":0,"confirmed-round":12361696,"fee":1000,"first-valid":12361693,"genesis-hash":"SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=","genesis-id":"testnet-v1.0","id":"VQSZLDQVOLBU65W4UWFDWBGMZHGU5KVKNCPL6P3GQ7W6DOJRTEWQ","intra-round-offset":0,"last-valid":12362693,"local-state-delta":[{"address":"RZ5AZRAQF2GRL32PIM6T67W4WOUKIS3HXB3HHSSH6YDZYT5CI2SNQZGZEA","delta":[{"key":"YmFsYW5jZQ==","value":{"action":2,"uint":0}},{"key":"bG9ja1VudGls","value":{"action":2,"uint":0}},{"key":"bWF4QmFsYW5jZQ==","value":{"action":2,"uint":0}},{"key":"dHJhbnNmZXJHcm91cA==","value":{"action":2,"uint":1}}]}],"note":"qnRlc3Qgb3B0SW4=","receiver-rewards":0,"round-time":1613386979,"sender":"RZ5AZRAQF2GRL32PIM6T67W4WOUKIS3HXB3HHSSH6YDZYT5CI2SNQZGZEA","sender-rewards":100,"signature":{"sig":"jyNWv/UotKTDi4x0yHG54pCreYCsbSefiLjVwow2nUHtEiBbUWz2QVRPTYse4emjiJ0j+1ft30ciNR/S9t9tBw=="},"tx-type":"appl"}}'
exports.optInToApp = async function optInToApp(envs) {
  const mnemonic = "turtle basic force reject inspire orchard believe lucky remain true purpose pulse museum school salt flame addict fortune solar brand giggle material bomb absent grab"
  const algoChain = new chainjs.ChainFactory().create(chainjs.ChainType.AlgorandV1, exports.algoTestnetEndpoints(envs.purestakeApi))
  const { addr, sk } = algosdk.mnemonicToSecretKey(mnemonic)

  await algoChain.connect()
  if (algoChain.isConnected) { console.log(`Connected to ${algoChain.chainId}`) }
  const transaction = await algoChain.new.Transaction()
  const txn = {
    from: addr,
    note: 'test optIn',
    appIndex: 13997710,
  }
  const action = await algoChain.composeAction(chainjs.ModelsAlgorand.AlgorandChainActionType.AppOptIn, txn)
  transaction.actions = [action]
  await transaction.prepareToBeSigned()
  await transaction.validate()
  await transaction.sign([chainjs.HelpersAlgorand.toAlgorandPrivateKey(sk)])

  try {
    console.log('send response: %o', JSON.stringify(await transaction.send(chainjs.Models.ConfirmType.After001)))
  } catch (err) {
    console.error(err)
  }
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

exports.updateTransactionHash = async function updateTransactionHash(blockchainTransaction, envs) {
  const blockchainTransactionsUrl = `${envs.comakeryServerUrl}/api/v1/projects/${envs.projectId}/blockchain_transactions/${blockchainTransaction.id}`
  const params = { body: { data: { transaction: { tx_hash: blockchainTransaction.txHash } } } }
  const config = { headers: { "API-Transaction-Key": envs.projectApiKey } }

  try {
    const res = await axios.put(blockchainTransactionsUrl, params, config)
    if (res.status == 200) {
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

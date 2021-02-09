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
  try {
    redisClient.hset(keyName, "address", wallet.address, "mnemonic", wallet.mnemonic)
  } catch (err) {
    return `Can't set a wallet key: ${err}`
  }
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
  } catch (error) {
    console.error(error)
    // console.error(`registerHotWallet call failed with ${error.response.status} (${error.response.statusText})`)
    return false
  }
  return true
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

require('dotenv').config()
const algosdk = require('algosdk')
const redis = require("redis")
const axios = require('axios')

const projectId = process.env.PROJECT_ID
const projectApiKey = process.env.PROJECT_API_KEY
const comakeryServerUrl = process.env.COMAKERY_SERVER_URL
const purestakeApi = process.env.PURESTAKE_API
const redisUrl = process.env.REDIS_URL

const keyName = `wallet_for_project_${projectId}`
const registerHotWalletPath = `/api/v1/projects/${projectId}/hot_wallet_addresses`
const redisClient = redis.createClient(redisUrl)

function generateAlgorandKeyPair() {
  const account = algosdk.generateAccount()
  const mnemonic = algosdk.secretKeyToMnemonic(account.sk);
  const new_wallet = { address: account.addr, mnemonic: mnemonic }

  return new_wallet
}

function isAllVariablesSet() {
  projectId === undefined || projectApiKey === undefined || comakeryServerUrl === undefined ||
    purestakeApi === undefined || redisUrl === undefined
}

function initialize() {
  if (isAllVariablesSet()) { return "Some ENV vars was not set" }

  setRedisErrorHandler(redisClient)

  redisClient.hgetall(keyName, function (err, walletKeys) {
    if (err) { return "Can't get a wallet keys: " + err }

    if (walletKeys) {
      console.log("wallet already created, do nothing...")
    } else {
      console.log("Key file does not exists, generating...")
      var newWallet = generateAlgorandKeyPair()
      registerHotWallet(newWallet)
    }
  })

  return false // no errors
}

function registerHotWallet(wallet) {
  const url = comakeryServerUrl + registerHotWalletPath
  const params = { body: { data: { hot_wallet: { address: wallet.address } } } }
  const config = { headers: { "API-Transaction-Key": projectApiKey }}
  axios
    .post(url, params, config)
    .then(res => {
      console.log("Hot wallet address has been registered")
      if (res.status == 201) { storeHotWalletKeys(wallet) }
    })
    .catch(error => {
      console.error(error)
      console.error(`registerHotWallet call failed with ${error.response.status} (${error.response.statusText})`)
    })
}

function storeHotWalletKeys(wallet) {
  redisClient.hset(keyName, "address", wallet.address, "mnemonic", wallet.mnemonic, function (err) {
    return `Can't set a wallet key: ${err}`
  })
  console.log(`Keys for a new hot wallet has been saved into ${keyName}`)
}

function setRedisErrorHandler(redisClient) {
  redisClient.on("error", function (err) {
    console.error(`Redis client error: ${err}`);
  });
}

function deleteCurrentKey() {
  redisClient.del(keyName)
  console.log(`Wallet keys has been deleted: ${keyName}`)
}

(async () => {
  // deleteCurrentKey()
  const res = initialize()
  if (res) { console.error(res); }
})();

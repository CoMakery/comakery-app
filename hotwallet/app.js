require('dotenv').config()
const algosdk = require('algosdk')
const redis = require("redis");

const projectId = process.env.PROJECT_ID
const projectApiKey = process.env.PROJECT_API_KEY
const comakeryServerUrl = process.env.COMAKERY_SERVER_URL
const purestakeApi = process.env.PURESTAKE_API
const redisUrl = process.env.REDIS_URL

const keyName = "wallet_for_project_" + projectId

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

  const redisClient = redis.createClient(redisUrl)
  setRedisErrorHandler(redisClient)

  redisClient.hgetall(keyName, function (err, wallet_keys) {
    if (err) { return "Can't get a wallet keys: " + err }

    if (wallet_keys) {
      console.error("wallet already created, do nothing...")
    } else {
      console.log("Key file does not exists, generating...")
      var new_wallet = generateAlgorandKeyPair()
      // TODO: call Comakery API to register the wallet and save file bellow on succesfull response

      redisClient.hset(keyName, "address", new_wallet.address, "mnemonic", new_wallet.mnemonic, function (err) {
        return "Can't set a wallet key: " + err
      })
    }
  })

  return false // no errors
}

function setRedisErrorHandler(redisClient) {
  redisClient.on("error", function (err) {
    console.error("Redis client error: " + err);
  });
}

function deleteCurrentKey() {
  const redisClient = redis.createClient(redisUrl)
  redisClient.del(keyName)
  console.log("Wallet keys has been deleted: " + keyName)
}

(async () => {
  // deleteCurrentKey()
  const res = initialize()
  if (res) { console.error(res); }
})();

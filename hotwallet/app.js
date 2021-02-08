require('dotenv').config()
const redis = require("redis")
const hwUtils = require('./lib/hotwalletUtils')

const envs = {
  projectId: process.env.PROJECT_ID,
  projectApiKey: process.env.PROJECT_API_KEY,
  comakeryServerUrl: process.env.COMAKERY_SERVER_URL,
  purestakeApi: process.env.PURESTAKE_API,
  redisUrl: process.env.REDIS_URL
}

const redisClient = redis.createClient(envs.redisUrl)

async function initialize() {
  if (!hwUtils.checkAllVariablesAreSet(envs)) { return "Some ENV vars was not set" }

  hwUtils.setRedisErrorHandler(redisClient)

  const keyName = hwUtils.keyName(envs.projectId)

  redisClient.hgetall(keyName, function (err, walletKeys) {
    if (err) { return "Can't get a wallet keys: " + err }

    if (walletKeys) {
      console.log("wallet already created, do nothing...")
    } else {
      console.log("Key file does not exists, generating...")
      var newWallet = hwUtils.generateAlgorandKeyPair()
      hwUtils.registerHotWallet(newWallet, envs, redisClient)
    }
  })

  return false // no errors
}

function deleteCurrentKey() {
  redisClient.del(keyName)
  console.log(`Wallet keys has been deleted: ${keyName}`)
}

(async () => {
  // deleteCurrentKey()
  const res = await initialize()
  if (res) { console.error(res); }
})();

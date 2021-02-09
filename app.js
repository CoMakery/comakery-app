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
  hwUtils.hotWalletInitialization(envs, redisClient)

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

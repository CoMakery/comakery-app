require("dotenv").config()
const redis = require("redis")
const hwUtils = require("./lib/hotwalletUtils")

const envs = {
  projectId: process.env.PROJECT_ID,
  projectApiKey: process.env.PROJECT_API_KEY,
  comakeryServerUrl: process.env.COMAKERY_SERVER_URL,
  purestakeApi: process.env.PURESTAKE_API,
  redisUrl: process.env.REDIS_URL,
  checkForNewTransactionsDelay: parseInt(process.env.CHECK_FOR_NEW_TRANSACTIONS_DELAY),
  optInApp: parseInt(process.env.OPT_IN_APP),
  blockchainNetwork: process.env.BLOCKCHAIN_NETWORK,
  maxAmountForTransfer: parseInt(process.env.MAX_AMOUNT_FOR_TRANSFER)
}

const redisClient = redis.createClient(envs.redisUrl)

async function initialize() {
  if (!hwUtils.checkAllVariablesAreSet(envs)) {
    // added by oleg
    console.log("Some ENV vars was not set")
    return false
  }
  return await hwUtils.hotWalletInitialization(envs, redisClient)
}

(async () => {
  const initialized = await initialize()
  if (initialized) {
    hwUtils.runServer(envs, redisClient)
  }
})();

require("dotenv").config()
const redis = require("redis")
const hwUtils = require("./lib/hotwalletUtils")
const chainjs = require("@open-rights-exchange/chainjs")

const envs = {
  projectId: process.env.PROJECT_ID,
  projectApiKey: process.env.PROJECT_API_KEY,
  comakeryServerUrl: process.env.COMAKERY_SERVER_URL,
  purestakeApi: process.env.PURESTAKE_API,
  redisUrl: process.env.REDIS_URL
}

const redisClient = redis.createClient(envs.redisUrl)

const algoMainnetEndpoints = [{
  url: 'https://mainnet-algorand.api.purestake.io/ps2',
  options: { indexerUrl: 'https://mainnet-algorand.api.purestake.io/idx2', headers: [{ 'x-api-key': envs.purestakeApi }] },
}]
const algoTestnetEndpoints = [ {
  url: 'https://testnet-algorand.api.purestake.io/ps2',
  options: { indexerUrl: 'https://testnet-algorand.api.purestake.io/idx2', headers: [{ 'x-api-key': envs.purestakeApi }] },
}]
const algoBetanetEndpoints = [{
  url: 'https://betanet-algorand.api.purestake.io/ps2',
  options: { indexerUrl: 'https://betanet-algorand.api.purestake.io/idx2', headers: [{ 'x-api-key': envs.purestakeApi }] },
}]
const composeValueTransferParams = {
  fromAccountName: "WDD3X6B4WFQDCH5N345I4F47LP5KCBI7YCDWFPJ2NO3YBNGQXBMYXT7T7U",
  toAccountName: 'GD64YIY3TWGDMCNPP553DZPPR6LDUSFQOIJVFDPPXWEG3FVOJCCDBBHU5A',
  amount: 100,
  symbol: "microalgo",
  memo: 'Hot wallet transactions',
}

async function initialize() {
  if (!hwUtils.checkAllVariablesAreSet(envs)) { return "Some ENV vars was not set" }

  hwUtils.setRedisErrorHandler(redisClient)
  hwUtils.hotWalletInitialization(envs, redisClient)

  return true
}

(async () => {
  // await hwUtils.deleteCurrentKey(envs, redisClient)
  await initialize()
  // hwUtils.runServer(envs, redisClient)

  const algoChain = new chainjs.ChainFactory().create(chainjs.ChainType.AlgorandV1, algoTestnetEndpoints)
  await algoChain.connect()
  if (algoChain.isConnected) {
    console.log(`Connected to ${algoChain.chainId}`)
  }

  const transaction = await algoChain.new.Transaction()
  const action = await algoChain.composeAction(chainjs.Models.ChainActionType.ValueTransfer, composeValueTransferParams)
  transaction.actions = [action]
  console.log('transaction actions: ', transaction.actions[0])
  const decomposed = await algoChain.decomposeAction(transaction.actions[0])
  console.log('decomposed actions: ', decomposed)
  const suggestedFee = await transaction.getSuggestedFee(chainjs.Models.TxExecutionPriority.Average)
  console.log('suggestedFee: ', suggestedFee)
  await transaction.setDesiredFee(suggestedFee)
  await transaction.prepareToBeSigned()
  await transaction.validate()
})();

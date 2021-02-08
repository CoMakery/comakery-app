const algosdk = require('algosdk')

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

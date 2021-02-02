require('dotenv').config()
const algosdk = require('algosdk')
const fs = require('fs')

const projectId = process.env.PROJECT_ID
const projectApiKey = process.env.PROJECT_API_KEY
const comakeryServerUrl = process.env.COMAKERY_SERVER_URL
const purestakeApi = process.env.PURESTAKE_API

function generateAlgorandKeyPair() {
  const account = algosdk.generateAccount()
  const mnemonic = algosdk.secretKeyToMnemonic(account.sk);
  const new_wallet = { address: account.addr, mnemonic: mnemonic }

  console.log("address: " + new_wallet.address)
  console.log( "Mnemonic: " + new_wallet.mnemonic )

  return new_wallet
}

function initialize() {
  if (projectId === undefined || projectApiKey === undefined || comakeryServerUrl === undefined || purestakeApi === undefined) {
    return "Some ENV vars was not set"
  }
  const key_filename = "wallet_for_project_" + projectId + ".key"

  if (fs.existsSync(key_filename)) {
    return "wallet already created, do nothing..."
  } else {
    console.log("Key file does not exists, generating...")
    var new_wallet = generateAlgorandKeyPair()
    // TODO: call Comakery API to register the wallet and save file bellow on succesfull response
    fs.writeFile(key_filename, JSON.stringify(new_wallet), 'utf8', function (err) {
      if (err) {
        return "Can't write into key file" + key_filename + "\n" + err
      }
    })
  }
  return null
}

(async () => {
  const res = initialize()
  if (res) { console.error(res); }
})();

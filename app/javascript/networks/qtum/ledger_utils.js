import config from 'networks/qtum/config'
import Wallet from 'networks/qtum/ledger/wallet'
import debugLog from 'src/javascripts/debugLog'
import caValidator from 'wallet-address-validator'
import utils from 'networks/helpers/utils'

const transferQtumCoins = async function(award) { // award in JSON
  const fee = 0.0015
  const network = award.token.blockchain_network.replace('qtum_', '')
  const recipientAddress = award.account.qtum_wallet
  let amount = parseFloat(award.total_amount)

  if (!recipientAddress || recipientAddress === '' || amount <= 0 || !(network === 'mainnet' || network === 'testnet')) {
    return
  }
  let txHash
  try {
    const networkType = network === 'mainnet' ? 'prod' : 'testnet'
    const addressValid = caValidator.validate(recipientAddress, 'QTUM', networkType)
    if (addressValid) {
      window.alertMsg('#metamaskModal1', 'Waiting...')
      txHash = await submitTransaction(network, recipientAddress, amount, fee)
    }
  } catch (err) {
    console.log(err)
    window.alertMsg('#metamaskModal1', err.message || 'The transaction failed')
    utils.showMessageWhenTransactionFailed(award)
  }
  if (txHash) {
    const sub = network === 'mainnet' ? 'explorer' : 'testnet'
    const link = `https://${sub}.qtum.org/tx/${txHash}`
    utils.updateTransactionAddress(award, txHash, link)
  }
  return txHash
}

// amount, fee in QTUM
// network: 'mainnet' or 'testnet'
const submitTransaction = async function(network, to, amount, fee) {
  config.set('network', network)
  const server = require('networks/qtum/server').default
  let path
  switch (network) {
    case 'testnet':
      path = "m/44'/1'/0'/0"
      break
    case 'mainnet':
      path = "m/44'/88'/0'/0"
      break
    default:
  }
  const ledger = await Wallet.connectLedger()
  debugLog('ledger ...........')
  debugLog(ledger)
  const hdNode = await Wallet.restoreHdNodeFromLedgerPath(ledger, path)

  debugLog(hdNode)
  let wallet
  Wallet.restoreFromHdNodeByPage(hdNode, 0, 1).forEach((item) => {
    debugLog('item ...........')
    wallet = item.wallet
    wallet.extend.ledger.path += '/' + item.path
  })
  debugLog(wallet)
  const fromAddress = wallet.info.address
  const info = await server.currentNode().getInfo(fromAddress)
  if (amount + fee >= info.balance) {
    const sub = network === 'mainnet' ? 'explorer' : 'testnet'
    const link = `https://${sub}.qtum.org/address/${fromAddress}`
    throw Error(`Account <a href='${link}' target='_blank'>${fromAddress}</a> <br> You don't have sufficient Tokens to send`)
  }
  const serializedTx = await wallet.generateTx(to, amount, fee)
  if (serializedTx) {
    const txId = await server.currentNode().sendRawTx(serializedTx)
    return txId
  } else {
    throw Error('The transaction failed')
  }
}

export default { transferQtumCoins, submitTransaction }

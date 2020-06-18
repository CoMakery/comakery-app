import Eos from 'eosjs'
import debugLog from 'src/javascripts/debugLog'
import EosUtils from 'networks/eos/nodes/utils'
import ScatterJS from 'scatterjs-core'
import ScatterEOS from 'scatterjs-plugin-eosjs'
import utils from 'networks/helpers/utils'

ScatterJS.plugins(new ScatterEOS())

const transferEosCoins = async function(award) { // award in JSON
  const network = award.token.blockchain_network.replace('eos_', '')
  const recipientAddress = award.account.eos_wallet
  let amount = parseFloat(award.total_amount)
  if (!recipientAddress || recipientAddress === '' || amount <= 0 || !(network === 'mainnet' || network === 'testnet')) {
    return
  }
  let txHash
  try {
    txHash = await submitTransaction(network, recipientAddress, amount)
  } catch (err) {
    console.error(err)
    alert(err.message || 'The transaction failed')
    utils.showMessageWhenTransactionFailed(award)
  }
  if (txHash) {
    const sub = network === 'mainnet' ? 'explorer.eosvibes.io' : 'jungle.bloks.io'
    const link = `https://${sub}/transaction/${txHash}`
    utils.updateTransactionAddress(award, txHash, link)
  }
  return txHash
}

// amount in EOS
// network: 'mainnet' or 'testnet'
const submitTransaction = async function(network, to, amount, memo = 'CoMakery') {
  const nodeHost = network === 'mainnet' ? 'explorer.eosvibes.io' : 'jungle.bloks.io'
  network = (network === 'mainnet') ? EosUtils.mainNet : EosUtils.testNet
  const connected = await ScatterJS.connect('ComakeryAppName', {network})
  if (!connected) return
  if (!await ScatterJS.login()) return
  const account = ScatterJS.account('eos')
  debugLog(account)
  const eos = ScatterJS.eos(network, Eos)
  const info = await eos.getAccount(account.name)
  debugLog(['account info: ', info])
  if (amount >= parseFloat(info.core_liquid_balance)) {
    const link = `https://${nodeHost}/account/${account.name}`
    throw Error(`Account <a href='${link}' target='_blank'>${account.name}</a> <br> You don't have sufficient Tokens to send`)
  }
  debugLog(`recipientAddress: ${to}`)
  const rs = await eos.transfer(account.name, to, `${amount.toFixed(4)} EOS`, memo)
  debugLog(['result: ', rs])
  if (rs.broadcast) {
    return rs.transaction_id
  }
}

export default { transferEosCoins }

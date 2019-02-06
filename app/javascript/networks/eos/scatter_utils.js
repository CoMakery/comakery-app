import Eos from 'eosjs'
import jQuery from 'jquery'
import debugLog from 'src/javascripts/debugLog'
import EosUtils from 'networks/eos/nodes/utils'
import ScatterJS from 'scatterjs-core'
import ScatterEOS from 'scatterjs-plugin-eosjs'

ScatterJS.plugins(new ScatterEOS())

const transferEosCoins = async function(award) { // award in JSON
  const network = award.project.blockchain_network.replace('eos_', '')
  const recipientAddress = award.account.eos_wallet
  let amount = parseFloat(award.total_amount)
  if (!recipientAddress || recipientAddress === '' || amount <= 0 || !(network === 'mainnet' || network === 'testnet')) {
    return
  }
  try {
    window.alertMsg('#metamaskModal1', 'Waiting...')
    const txHash = await submitTransaction(network, recipientAddress, amount)
    debugLog('transaction address: ' + txHash)
    if (txHash) {
      jQuery.post('/projects/' + award.project.id + '/awards/' + award.id + '/update_transaction_address', { tx: txHash })
    }
    window.foundationCmd('#metamaskModal1', 'close')
    return txHash
  } catch (err) {
    console.error(err)
    if (err.name === 'ErrorMessage') {
      window.alertMsg('#metamaskModal1', err.message)
    } else {
      window.foundationCmd('#metamaskModal1', 'close')
    }
    if (jQuery('body.projects-show').length > 0) {
      jQuery('.flash-msg').html('The tokens have been awarded but not transferred. You can transfer tokens on the blockchain on the <a href="/projects/' + award.project.id + '/awards">awards</a> page.')
    }
  }
}

// amount in EOS
// network: 'mainnet' or 'testnet'
const submitTransaction = async function(network, to, amount, memo = 'CoMakery') {
  const networkObj = network === 'mainnet' ? EosUtils.mainNet : EosUtils.testNet
  const connected = await ScatterJS.connect('ComakeryAppName', {networkObj})
  if (!connected) return
  if (!await ScatterJS.login()) return
  console.log('Signed in successfully')
  const account = ScatterJS.account('eos')
  debugLog(account)
  const eos = ScatterJS.eos(networkObj, Eos)
  debugLog(eos)
  debugLog(`recipientAddress: ${to}`)
  const rs = await eos.transfer(account.name, to, `${amount.toFixed(4)} EOS`, memo)
  debugLog(['result: ', rs])
  if (rs.broadcast) {
    return rs.transaction_id
  }
}

export default { transferEosCoins }

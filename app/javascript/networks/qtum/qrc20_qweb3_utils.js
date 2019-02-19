import jQuery from 'jquery'
import debugLog from 'src/javascripts/debugLog'
import { Qweb3 } from 'qweb3'
import qrc20TokenABI from 'networks/qtum/qrc20_token_abi'

const getQtumBalance = async function(contract, owner) {
  const rs = await contract.call('balanceOf', {
    methodArgs: [owner]
  })
  return rs.executionResult.formattedOutput[0].toNumber()
}

const transferQrc20Tokens = async function(award) { // award in JSON
  const contractAddress = award.token.contract_address
  const recipientAddress = award.account.qtum_wallet
  let amount = award.amount_to_send
  if (!recipientAddress || recipientAddress === '' || !contractAddress || contractAddress === '' || amount <= 0) {
    return
  }
  if (!window.qrypto.account.loggedIn) {
    if (jQuery('body.projects-show').length > 0) {
      jQuery('.flash-msg').html('The tokens have been awarded but not transferred because you are not logged in to the Qrypto wallet browser extension. You can transfer tokens on the blockchain with Qrypto on the <a href="/projects/' + award.project.id + '/awards">awards</a> page.')
    }
    window.alertMsg('#metamaskModal1', 'Not logged in. Please log in to Qrypto first')
    return
  }
  const qweb3 = new Qweb3(window.qrypto.rpcProvider)
  const contract = qweb3.Contract(contractAddress, qrc20TokenABI)
  debugLog(amount)
  const balance = await getQtumBalance(contract, window.qrypto.account.address)
  debugLog(balance)
  if (balance < amount) {
    window.alertMsg('#metamaskModal1', "You don't have sufficient Tokens to send")
    return
  }
  const rs = await contract.send('transfer', {
    methodArgs   : [recipientAddress, amount],
    gasPrice     : 0.00000040,
    gasLimit     : 1000000,
    senderAddress: window.qrypto.account.address,
  })
  debugLog('transaction address: ' + rs.txid)
  jQuery.post('/projects/' + award.project.id + '/awards/' + award.id + '/update_transaction_address', { tx: rs.txid })
}

export default { transferQrc20Tokens }

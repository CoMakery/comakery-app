/* eslint-disable no-alert, no-undef, complexity, standard/object-curly-even-spacing */

window.postMessage({ message: { type: 'CONNECT_QRYPTO' }}, '*')

const { Qweb3 } = require('qweb3')

getQtumBalance = async function(contract, owner) {
  const rs = await contract.call('balanceOf', {
    methodArgs: [owner]
  })
  return rs.executionResult.formattedOutput[0].toNumber()
}

transferQrc20Tokens = async function(award) { // award in JSON
  contractAddress = award.project.contract_address
  recipientAddress = award.account.qtum_wallet
  amount = award.amount_to_send
  if (!recipientAddress || recipientAddress === '' || !contractAddress || contractAddress === '' || amount <= 0) {
    return
  }
  if (!window.qrypto.account.loggedIn) {
    if ($('body.projects-show').length > 0) {
      $('.flash-msg').html('The tokens have been awarded but not transferred because you are not logged in to the Qrypto wallet browser extension. You can transfer tokens on the blockchain with Qrypto on the <a href="/projects/' + award.project.id + '/awards">awards</a> page.')
    }
    alertMsg($('#metamaskModal1'), 'Not logged in. Please log in to Qrypto first')
    return
  }
  const qweb3 = new Qweb3(window.qrypto.rpcProvider)
  const contract = qweb3.Contract(contractAddress, qrc20TokenABI)
  console.log(amount)
  const balance = await getQtumBalance(contract, window.qrypto.account.address)
  console.log(balance)
  if (balance < amount) {
    alertMsg($('#metamaskModal1'), "You don't have sufficient Tokens to send")
    return
  }
  const rs = await contract.send('transfer', {
    methodArgs   : [recipientAddress, amount],
    gasLimit     : 1000000,
    senderAddress: window.qrypto.account.address,
  })
  console.log('transaction address: ' + rs.txid)
  $.post('/projects/' + award.project.id + '/awards/' + award.id + '/update_transaction_address', { tx: rs.txid })
}

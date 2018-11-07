/* eslint-disable no-alert, no-undef, complexity, standard/object-curly-even-spacing */

window.postMessage({ message: { type: 'CONNECT_QRYPTO' }}, '*')

const { Qweb3 } = require('qweb3')

getQtumSymbolsAndDecimals = async function(network, contractAddress) {
  if (!window.qrypto.account.loggedIn) {
    alertMsg($('#metamaskModal1'), 'Not logged in. Please log in to Qrypto first')
    return
  }
  if (network !== 'qtum_' + window.qrypto.account.network.toLowerCase()) {
    alertMsg($('#metamaskModal1'), 'Please select ' + network.split('_').join(' '))
    return
  }
  const qweb3 = new Qweb3(window.qrypto.rpcProvider)
  const contract = qweb3.Contract(contractAddress, qrc20TokenABI)
  let rs = await contract.call('symbol', {
    methodArgs: []
  })
  const symbol = rs.executionResult.formattedOutput[0]

  rs = await contract.call('decimals', {
    methodArgs: []
  })
  const decimals = rs.executionResult.formattedOutput[0].toNumber()
  return [symbol, decimals]
}

getQtumDecimals = async function(contract) {
  const rs = await contract.call('decimals', {
    methodArgs: []
  })
  return rs.executionResult.formattedOutput[0].toNumber()
}

getQtumBalance = async function(contract, owner) {
  const rs = await contract.call('balanceOf', {
    methodArgs: [owner]
  })
  return rs.executionResult.formattedOutput[0].toNumber()
}

transferQrc20Tokens = async function(contractAddress, recipientAddress, amount) {
  amount = parseInt(amount, 10)
  if (recipientAddress === '' || contractAddress === '' || amount <= 0) {
    alert('Please enter all fields')
    return
  }
  if (!window.qrypto.account.loggedIn) {
    alert('Not logged in. Please log in to Qrypto first')
    return
  }
  const qweb3 = new Qweb3(window.qrypto.rpcProvider)

  const contract = qweb3.Contract(contractAddress, qrc20TokenABI)
  const decimals = await getQtumDecimals(contract)
  console.log(decimals)
  console.log(amount * 10 ** decimals)
  const balance = await getQtumBalance(contract, window.qrypto.account.address)
  console.log(balance)
  if (balance < amount * 10 ** decimals) {
    alert("You don't have sufficient Tokens to send")
    return
  }
  const rs = await contract.send('transfer', {
    methodArgs   : [recipientAddress, amount * 10 ** decimals],
    gasLimit     : 1000000,
    senderAddress: window.qrypto.account.address,
  })
  console.log(rs.txid)
  $('#result').html("Transaction: <a href='https://testnet.qtum.org/tx/" + rs.txid + "' target='_blank'>" + rs.txid + '</a>')
  return rs.txid
}

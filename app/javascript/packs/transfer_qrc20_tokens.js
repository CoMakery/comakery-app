window.postMessage({ message: { type: 'CONNECT_QRYPTO' }}, '*')

const { Qweb3 } = require('qweb3');

getDecimals = async function(contract) {
  const rs = await contract.call('decimals', {
    methodArgs: []
  });
  return rs['executionResult']['formattedOutput'][0].toNumber()
}

getBalance = async function(contract, owner) {
  const rs = await contract.call('balanceOf', {
    methodArgs: [owner]
  });
  return rs['executionResult']['formattedOutput'][0].toNumber()
}

transferQrc20Tokens = async function(contractAddress, recipientAddress, amount) {
  amount = parseInt(amount, 10)
  if(recipientAddress == '' || contractAddress == '' || amount <= 0) {
    alert('Please enter all fields')
    return;
  }
  if(!window.qrypto.account.loggedIn) {
    alert('Not logged in. Please log in to Qrypto first')
    return;
  }
  const qweb3 = new Qweb3(window.qrypto.rpcProvider);

  const contract = qweb3.Contract(contractAddress, qrc20TokenABI);
  const decimals = await getDecimals(contract)
  console.log(decimals)
  console.log(amount * 10 ** decimals)
  const balance = await getBalance(contract, window.qrypto.account.address)
  console.log(balance)
  if(balance < amount * 10 ** decimals) {
    alert("You don't have sufficient Tokens to send")
    return;
  }
  const rs = await contract.send('transfer', {
    methodArgs: [recipientAddress, amount * 10 ** decimals],
    gasLimit: 1000000,
    senderAddress: window.qrypto.account.address,
  });
  console.log(rs['txid'])
  $('#result').html("Transaction: <a href='https://testnet.qtum.org/tx/" + rs['txid'] + "' target='_blank'>" + rs['txid'] + "</a>")
  return rs['txid'];
}

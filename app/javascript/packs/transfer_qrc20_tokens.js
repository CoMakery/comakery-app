window.postMessage({ message: { type: 'CONNECT_QRYPTO' }}, '*')

const { Qweb3 } = require('qweb3');

transferQrc20Tokens = async function(recipientAddress) {
  if(recipientAddress == '') {
    alert('Please enter recipient address')
    return;
  }
  if(!window.qrypto.account.loggedIn) {
    console.log('Not logged in. Please log in to Qrypto first')
    return;
  }
  const qweb3 = new Qweb3(window.qrypto.rpcProvider);
  const contractAddress = '6797155d96718b58ddde3ba02c5173b6ee4e8581';

  const contract = qweb3.Contract(contractAddress, qrc20TokenABI);

  const rs = await contract.send('transfer', {
    methodArgs: [recipientAddress, 5 * 10**8],
    gasLimit: 1000000,
    senderAddress: window.qrypto.account.address,
  });
  console.log(rs['txid'])
  $('#result').html("Transaction: <a href='https://testnet.qtum.org/tx/" + rs['txid'] + "' target='_blank'>" + rs['txid'] + "</a>")
  return rs['txid'];
}

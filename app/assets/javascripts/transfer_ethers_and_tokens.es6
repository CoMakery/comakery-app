async function transferAwardOnEthereum(award) { // award in JSON
  var web3;
  if (window.ethereum) {
    window.web3 = new Web3(ethereum);
  }
  if (!window.web3) {
    alertMsg($('#metamaskModal1'), 'Please unlock your MetaMask Accounts');
    return;
  }
  if (!web3) {
    web3 = new Web3(window.web3.currentProvider);
  }
  if (!web3.eth.coinbase && window.ethereum) {
    await(ethereum.enable());
  }
  if (!web3.eth.coinbase) {
    alertMsg($('#metamaskModal1'), 'Please unlock your MetaMask Accounts');
    return;
  }
  if (award.project.coin_type === 'erc20') {
    transferTokens(award);
  } else if (award.project.coin_type === 'eth') {
    transferEthers(award);
  }
};

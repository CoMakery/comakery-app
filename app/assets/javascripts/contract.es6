window.getSymbolsAndDecimals = function(network, contractAddress) {
  let contractABI, tokenContract, web3;
  if (network === 'main') {
    network = 'mainnet';
  }
  web3 = new Web3(new Web3.providers.HttpProvider("https://" + network + ".infura.io"));
  contractABI = abi;
  tokenContract = web3.eth.contract(contractABI).at(contractAddress);
  try {
    return [tokenContract.symbol(), tokenContract.decimals().toNumber()];
  } catch (error) {
    return ['', ''];
  }
};

window.getQtumSymbolsAndDecimals = async function(network, contractAddress) {
  let url, response, data;
  if (network === 'qtum_testnet') {
    url = 'https://testnet.qtum.info/api/contract/' + contractAddress;
  } else if (network === 'qtum_mainnet') {
    url = 'https://qtum.info/api/contract/' + contractAddress;
  }
  response = await fetch(url);
  data = await response.json()
  return [data.qrc20.symbol, data.qrc20.decimals];
};

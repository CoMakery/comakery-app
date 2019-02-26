window.getSymbolsAndDecimals = async function(network, contractAddress) {
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
    return await getErc20SymbolsAndDecimalsFromEthplorer(contractAddress)
  }
};

window.getErc20SymbolsAndDecimalsFromEthplorer = async function(contractAddress) {
  const url = `https://api.ethplorer.io/getTokenInfo/${contractAddress}?apiKey=freekey`
  const rs = await fetch(url).then((response) =>
    response.json()
  )
  return [rs.symbol, rs.decimals]
}

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

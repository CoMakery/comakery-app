window.getSymbolsAndDecimals = (network, contractAddress) ->
  network = 'mainnet' if network == 'main'
  web3 = new Web3(new Web3.providers.HttpProvider("https://" + network + ".infura.io"))
  contractABI = abi
  tokenContract = web3.eth.contract(contractABI).at(contractAddress)
  try
    [tokenContract.symbol(), tokenContract.decimals().toNumber()]
  catch
    ['', '']

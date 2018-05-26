transferTokens = (web3, contractAddress, abi, amount, toAddress) ->
  contract = web3.eth.contract(abi) # see abi in abi.js
  contractIns = contract.at(contractAddress)
  contractIns.transfer toAddress, web3.toWei(amount, 'ether'), (err, data) ->
    console.log err
    console.log data

$ ->
  $(document).on 'click', '.transfer-tokens-btn', ->
    if !window.web3
      $('#metamaskModal1').foundation('open')
      return
    if !web3
      web3 = new Web3(window.web3.currentProvider)
    if !web3.eth.coinbase
      $('#metamaskModal1').foundation('open')
      return

    contractAddress = $('.transfer-tokens-form #project_ethereum_contract_address').val()
    toAddress = $('.transfer-tokens-form #receiver_address').val()
    amount = $('.transfer-tokens-form #amount').val()
    if contractAddress && toAddress && amount
      contract = web3.eth.contract(abi) # see abi in abi.js
      contractIns = contract.at(contractAddress)
      contractIns.transfer toAddress, web3.toWei(amount, 'ether'), (err, data) ->
        console.log err
        if data
          console.log data
          toAddress = $('.transfer-tokens-form #receiver_address').val('')
          amount = $('.transfer-tokens-form #amount').val('')

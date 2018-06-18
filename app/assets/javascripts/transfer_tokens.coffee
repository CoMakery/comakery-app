alertMsg = (modal, msg) ->
  modal.find('.alert-msg').text(msg)
  modal.foundation('open')

$ ->
  $(document).on 'click', '.transfer-tokens-btn', ->
    if !window.web3
      alertMsg $('#metamaskModal1'), 'Please unlock your MetaMask Accounts'
      return
    if !web3
      web3 = new Web3(window.web3.currentProvider)
    if !web3.eth.coinbase
      alertMsg $('#metamaskModal1'), 'Please unlock your MetaMask Accounts'
      return

    contractAddress = $('.transfer-tokens-form #project_ethereum_contract_address').val()
    toAddress = $('.transfer-tokens-form #receiver_address').val()
    amount = $('.transfer-tokens-form #amount').val()
    if contractAddress && toAddress && amount
      contract = web3.eth.contract(abi) # see abi in abi.js
      contractIns = contract.at(contractAddress)
      contractIns.balanceOf web3.eth.coinbase, (err, result) ->
        if result && parseFloat(balance = web3.fromWei(result.toNumber(), 'ether')) >= parseFloat(amount)
          contractIns.transfer toAddress, web3.toWei(amount, 'ether'), (err, data) ->
            console.log err if err
            if data
              console.log data
              toAddress = $('.transfer-tokens-form #receiver_address').val('')
              amount = $('.transfer-tokens-form #amount').val('')
        else
          alertMsg $('#metamaskModal1'), 'Amount should not be greater than balance ' + balance

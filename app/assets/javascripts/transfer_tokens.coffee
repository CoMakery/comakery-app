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
    data = JSON.parse $(this).attr('data-info')

    issuerAddress = data.issuer_address
    contractAddress = data.project.ethereum_contract_address
    toAddress = data.account.ethereum_wallet
    amount = data.total_amount
    if issuerAddress && contractAddress && toAddress && amount && issuerAddress.toLowerCase() == web3.eth.coinbase
      contract = web3.eth.contract(abi) # see abi in abi.js
      contractIns = contract.at(contractAddress)
      contractIns.balanceOf web3.eth.coinbase, (err, result) ->
        if result && parseFloat(balance = web3.fromWei(result.toNumber(), 'ether')) >= parseFloat(amount)
          contractIns.transfer toAddress, web3.toWei(amount, 'ether'), (err, tx) ->
            console.log err if err
            if tx
              console.log tx

        else
          alertMsg $('#metamaskModal1'), 'Amount should not be greater than balance ' + balance

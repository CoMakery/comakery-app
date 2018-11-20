window.transferTokens = (award) -> # award in JSON
  contractAddress = award.project.ethereum_contract_address
  toAddress = award.account.ethereum_wallet
  amount = award.amount_to_send

  if contractAddress && toAddress && amount
    contract = web3.eth.contract(abi) # see abi in abi.js
    contractIns = contract.at(contractAddress)
    contractIns.balanceOf web3.eth.coinbase, (err, result) ->
      if result && parseFloat(web3.fromWei(result.toNumber(), 'wei')) >= parseFloat(amount)
        contractIns.transfer toAddress, web3.toWei(amount, 'wei'), (err, tx) ->
          console.log err if err
          if tx
            console.log 'transaction address: ' + tx
            # update_transaction_address_project_award_path
            $.post('/projects/' + award.project.id + '/awards/' + award.id + '/update_transaction_address', tx: tx)
      else
        alertMsg $('#metamaskModal1'), "You don't have sufficient Tokens to send"

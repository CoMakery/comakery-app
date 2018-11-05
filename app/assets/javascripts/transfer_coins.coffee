window.transferEthers = (award) -> # award in JSON
  toAddress = award.account.ethereum_wallet
  amount = award.amount_to_send

  if toAddress && amount
    web3.eth.getBalance web3.eth.coinbase, (err, result) ->
      if result && parseFloat(web3.fromWei(result.toNumber(), 'wei')) >= parseFloat(amount)
        web3.eth.sendTransaction {
          from: web3.eth.coinbase
          to: toAddress
          value: web3.toWei(amount, 'wei')
        }, (err, tx) ->
          console.log err if err
          if tx
            console.log 'transaction address: ' + tx
            # update_transaction_address_project_award_path
            $.post('/projects/' + award.project.id + '/awards/' + award.id + '/update_transaction_address', tx: tx)
      else
        alertMsg $('#metamaskModal1'), "You don't have sufficient Tokens to send"

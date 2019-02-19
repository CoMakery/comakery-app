window.transferTokens = (award) -> # award in JSON
  contractAddress = award.token.ethereum_contract_address
  toAddress = award.account.ethereum_wallet
  amount = award.amount_to_send

  if contractAddress && toAddress && amount
    contract = web3.eth.contract(abi) # see abi in abi.js
    contractIns = contract.at(contractAddress)
    contractIns.balanceOf web3.eth.coinbase, (err, result) ->
      if result && parseFloat(web3.fromWei(result.toNumber(), 'wei')) >= parseFloat(amount)
        contractIns.transfer toAddress, web3.toWei(amount, 'wei'), { gasPrice: web3.toWei(1, 'gwei') }, (err, tx) ->
          if tx
            console.log 'transaction address: ' + tx
            # update_transaction_address_project_award_path
            $.post('/projects/' + award.project.id + '/awards/' + award.id + '/update_transaction_address', tx: tx)
            if $('body.projects-show').length > 0
              $('.flash-msg').html('Successfully sent award to ' + award.recipient_display_name)
          else if err
            console.log err
            alertMsg($('#metamaskModal1'), 'Errors occurred, please click on REJECT button. Please transfer ethers on the blockchain with MetaMask on the awards page. Please make sure that gas fee is greater than 0 before clicking on CONFIRM button on MetaMask popup')

      else
        alertMsg $('#metamaskModal1'), "You don't have sufficient Tokens to send"

window.alertMsg = (modal, msg) ->
  modal.find('.alert-msg').text(msg)
  modal.foundation('open')

window.transferAwardOnEthereum = (award) -> # award in JSON
  if !window.web3
    alertMsg $('#metamaskModal1'), 'Please unlock your MetaMask Accounts'
    return
  if !web3
    web3 = new Web3(window.web3.currentProvider)
  if !web3.eth.coinbase
    alertMsg $('#metamaskModal1'), 'Please unlock your MetaMask Accounts'
    return

  if award.project.coin_type == 'erc20'
    transferTokens award
  else if award.project.coin_type == 'eth'
    transferEthers award

window.transferAwardOnQtum = (award) -> # award in JSON
  transferQrc20Tokens award

window.transferAward = (award) -> # award in JSON
  if award.project.coin_type == 'erc20' || award.project.coin_type == 'eth'
    transferAwardOnEthereum award
  else if award.project.coin_type == 'qrc20'
    transferAwardOnQtum award

$ ->
  $(document).on 'click', '.transfer-tokens-btn', ->
    award = JSON.parse $(this).attr('data-info')
    transferAward award

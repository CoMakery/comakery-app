window.alertMsg = function(modal, msg) {
  $(modal).find('.alert-msg').html(msg)
  $(modal).foundation('open')
}

window.transferAwardOnQtum = function(award) { // award in JSON
  if (award.project.coin_type === 'qrc20') {
    qrc20Qweb3.transferQrc20Tokens(award)
  } else if (award.project.coin_type === 'qtum') {
    qtumLedger.transferQtumCoins(award)
  }
}

const transferAwardOnCardano = award => // award in JSON
  cardanoTrezor.transferAdaCoins(award)

const transferAwardOnBitcoin = award => // award in JSON
  bitcoinTrezor.transferBtcCoins(award)

const transferAwardOnEos = award => // award in JSON
  eosScatter.transferEosCoins(award)

window.transferAward = function(award) { // award in JSON
  if ((award.project.coin_type === 'erc20') || (award.project.coin_type === 'eth')) {
    transferAwardOnEthereum(award)
  } else if ((award.project.coin_type === 'qrc20') || (award.project.coin_type === 'qtum')) {
    transferAwardOnQtum(award)
  } else if (award.project.coin_type === 'ada') {
    transferAwardOnCardano(award)
  } else if (award.project.coin_type === 'btc') {
    transferAwardOnBitcoin(award)
  } else if (award.project.coin_type === 'eos') {
    transferAwardOnEos(award)
  }
}

$(() =>
  $(document).on('click', '.transfer-tokens-btn', function() {
    const award = JSON.parse($(this).attr('data-info'))
    transferAward(award)
  })
)

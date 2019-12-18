window.alertMsg = function(modal, msg, closeLabel) {
  $(modal).find('.alert-msg').html(msg)
  if (closeLabel) {
    $(modal).find('a[data-close]').html(closeLabel)
  }
  $(modal).foundation('open')
}

window.transferAwardOnQtum = function(award) { // award in JSON
  if (award.token.coin_type === 'qrc20') {
    qrc20Qweb3.transferQrc20Tokens(award)
  } else if (award.token.coin_type === 'qtum') {
    qtumLedger.transferQtumCoins(award)
  }
}

const transferAwardOnCardano = award => // award in JSON
  cardanoTrezor.transferAdaCoins(award)

const transferAwardOnBitcoin = award => // award in JSON
  bitcoinTrezor.transferBtcCoins(award)

const transferAwardOnEos = award => // award in JSON
  eosScatter.transferEosCoins(award)

const transferAwardOnTezos = award => // award in JSON
  tezosTrezor.transferXtzCoins(award)

window.transferAward = function(award) { // award in JSON
  if ((award.token.coin_type === 'qrc20') || (award.token.coin_type === 'qtum')) {
    transferAwardOnQtum(award)
  } else if (award.token.coin_type === 'ada') {
    transferAwardOnCardano(award)
  } else if (award.token.coin_type === 'btc') {
    transferAwardOnBitcoin(award)
  } else if (award.token.coin_type === 'eos') {
    transferAwardOnEos(award)
  } else if (award.token.coin_type === 'xtz') {
    transferAwardOnTezos(award)
  }
}

$(() =>
  $(document).on('click', '.transfer-tokens-btn:not(.transfer-tokens-btn-skip-legacy)', function() {
    const award = JSON.parse($(this).attr('data-info'))
    transferAward(award)
  })
)

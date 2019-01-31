window.cardanoTrezor = (function() {
  const trezorUtils = require('networks/cardano/trezor_utils').default

  const transferAdaCoins = function(award) { // award in JSON
    trezorUtils.transferAdaCoins(award)
  }

  return {
    transferAdaCoins
  }
})()

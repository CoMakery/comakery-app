window.bitcoinTrezor = (function() {
  const trezorUtils = require('networks/bitcoin/trezor_utils').default

  const transferBtcCoins = function(award) { // award in JSON
    trezorUtils.transferBtcCoins(award)
  }

  return {
    transferBtcCoins
  }
})()

/* eslint-disable no-undef */

window.bitcoinTrezor = (function() {
  const trezorUtils = require('networks/bitcoin/trezor_utils')

  const transferBtcCoins = function(award) { // award in JSON
    trezorUtils.transferBtcCoins(award)
  }

  return {
    transferBtcCoins
  }
})()

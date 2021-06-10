window.tezosTrezor = (function() {
  const trezorUtils = require('networks/tezos/trezor_utils').default

  const transferXtzCoins = function(award) { // award in JSON
    trezorUtils.transferXtzCoins(award)
  }

  return {
    transferXtzCoins
  }
})()

window.eosScatter = (function() {
  const scatterUtils = require('networks/eos/scatter_utils').default

  const transferEosCoins = function(award) { // award in JSON
    scatterUtils.transferEosCoins(award)
  }

  return {
    transferEosCoins
  }
})()

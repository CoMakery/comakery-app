window.qtumLedger = (function() {
  const ledgerUtils = require('networks/qtum/ledger_utils').default

  const transferQtumCoins = function(award) { // award in JSON
    ledgerUtils.transferQtumCoins(award)
  }

  return {
    transferQtumCoins
  }
})()

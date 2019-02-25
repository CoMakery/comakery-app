window.postMessage({message: { type: 'CONNECT_QRYPTO' }}, '*')

window.qrc20Qweb3 = (function() {
  const qweb3Utils = require('networks/qtum/qrc20_qweb3_utils.js').default

  const transferQrc20Tokens = function(award) { // award in JSON
    qweb3Utils.transferQrc20Tokens(award)
  }

  return {
    transferQrc20Tokens
  }
})()

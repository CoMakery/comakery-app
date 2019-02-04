const customBlockchainNetwork = function(coinType) {
  const $ = require('jquery')
  let prefix = ''
  switch (coinType) {
    case 'qtum':
    case 'qrc20':
      prefix = 'qtum_'
      break
    case 'ada':
      prefix = 'cardano_'
      break
    case 'btc':
      prefix = 'bitcoin_'
      break
    case 'eos':
      prefix = 'eos_'
      break
    default:
  }
  if (prefix !== '') {
    $("[name='project[blockchain_network]']").children('option:not(:first)').remove()
    let data = JSON.parse($("[name='project[blockchain_network]']").attr('data-info'))
    $.each(data, (k, v) => {
      if (k.startsWith(prefix)) {
        $("[name='project[blockchain_network]']").append(new Option(v, k))
      }
    })
  }
}

module.exports = customBlockchainNetwork
window.customBlockchainNetwork = customBlockchainNetwork

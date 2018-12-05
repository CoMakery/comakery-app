/* eslint-disable no-alert, no-undef, complexity, standard/object-curly-even-spacing */

const constants = require('networks/qtum/constants')
const bitcoinJsLib = require('bitcoinjs-lib')

// network: 'mainnet' or 'testnet'
convertQtumAddressToBitcoinType = function(qtumAddress, network) {
  const buffer = bitcoinJsLib.address.fromBase58Check(qtumAddress)
  const hash160 = buffer.hash

  return bitcoinJsLib.address.toBase58Check(hash160, constants.net[network].BITCOIN_ADDRTYPE_P2PKH)
}

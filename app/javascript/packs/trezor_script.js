/* eslint-disable no-alert, no-undef, complexity, standard/object-curly-even-spacing */

const constants = require('networks/qtum/constants')
const bitcoinJsLib = require('bitcoinjs-lib')
const qtumcore = require('qtumcore-lib')

// network: 'mainnet' or 'testnet'
getQtumAddressFromFirstPublicKey = async function(network) {
  let path, btcNetwork, qtumNetwork
  switch (network) {
    case 'testnet':
      path = "m/44'/1'/0'"
      btcNetwork = bitcoinJsLib.networks.testnet
      qtumNetwork = qtumcore.Networks.testnet
      break
    case 'mainnet':
      path = "m/44'/88'/0'"
      btcNetwork = bitcoinJsLib.networks.bitcoin
      qtumNetwork = qtumcore.Networks.mainnet
      break
    default:
  }
  const pubkeyRes = await TrezorConnect.getPublicKey({
    path: path,
    coin: 'qtum'
  })
  const xpub = pubkeyRes.payload.xpub
  const publicKey = bitcoinJsLib.bip32.fromBase58(xpub, btcNetwork).derive(0).derive(0).publicKey
  const address = qtumcore.Address.fromPublicKey(new qtumcore.PublicKey(publicKey), qtumNetwork)
  return address.toString()
}

// network: 'mainnet' or 'testnet'
convertQtumAddressToBitcoinType = function(qtumAddress, network) {
  const buffer = bitcoinJsLib.address.fromBase58Check(qtumAddress)
  const hash160 = buffer.hash

  return bitcoinJsLib.address.toBase58Check(hash160, constants.net[network].BITCOIN_ADDRTYPE_P2PKH)
}

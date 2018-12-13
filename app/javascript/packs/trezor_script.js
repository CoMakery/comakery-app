/* eslint-disable no-alert, no-undef, complexity, standard/object-curly-even-spacing, default-case */

const constants = require('networks/qtum/constants')
const config = require('networks/qtum/config').default
const bitcoinJsLib = require('bitcoinjs-lib')
const qtumJsLib = require('qtumjs-lib')
const qtumcore = require('qtumcore-lib')
const BigNumber = require('bignumber.js')

// network: 'mainnet' or 'testnet'
sendQtums = async function(network, to, amount) {
  const addressN = [2147483692, 2147483649, 2147483648, 0, 0]
  const coinName = network === 'mainnet' ? 'Bitcoin' : 'testnet'

  config.set('network', network)
  const server = require('networks/qtum/server').default
  const fee = 0.001582
  const rawTxFetchFunc = server.currentNode().fetchRawTx
  const fromAddress = await getQtumAddressFromFirstPublicKey(network)
  const toAddressInBtc = convertQtumAddressToBitcoinType(to, network)
  console.log('fromAddress = ' + fromAddress)
  console.log('recipient address in Qtum = ' + to)
  console.log('recipient address in Bitcoin type = ' + toAddressInBtc)
  const account = await server.currentNode().getInfo(fromAddress)
  if (amount >= account.balance) {
    alertMsg($('#metamaskModal1'), "You don't have sufficient Tokens to send")
    return
  }
  const utxoList = await server.currentNode().getUtxoList(fromAddress)
  console.log('utxoList .........')
  console.log(utxoList)
  const amountSat = new BigNumber(amount).times(1e8)
  const feeSat = new BigNumber(fee).times(1e8)
  const selectUtxo = qtumJsLib.utils.selectTxs(utxoList, amount, fee)
  const rawTxCache = {}
  console.log(selectUtxo)
  let inputs = []
  let prevTxHexList = []
  let totalSelectSat = new BigNumber(0)
  for (let i = 0; i < selectUtxo.length; i++) {
    const item = selectUtxo[i]
    console.log('item ............. ' + i)
    if (!rawTxCache[item.hash]) {
      rawTxCache[item.hash] = await rawTxFetchFunc(item.hash)
    }
    prevTxHexList.push(rawTxCache[item.hash])
    totalSelectSat = totalSelectSat.plus(item.value)
    inputs.push({
      address_n : addressN,
      prev_index: item.pos,
      prev_hash : item.hash
    })
  }
  const changeSat = totalSelectSat.minus(amountSat).minus(feeSat)
  const outputs = [
    {
      address_n  : addressN,
      amount     : changeSat.toString(),
      script_type: 'PAYTOADDRESS'
    }, {
      address    : toAddressInBtc,
      amount     : amountSat.toString(),
      script_type: 'PAYTOADDRESS'
    }
  ]
  const signed = await TrezorConnect.qtumSignTransaction({inputs: inputs, outputs: outputs, coin: coinName, push: false, prevTxHexList: prevTxHexList})

  const serializedTx = signed.payload.serializedTx
  if (serializedTx) {
    const txId = await server.currentNode().sendRawTx(serializedTx)
    console.log('txId =' + txId)
    return txId
  }
}

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

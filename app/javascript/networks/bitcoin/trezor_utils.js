import utils from 'networks/bitcoin/helpers/utils'
import insight from 'networks/bitcoin/nodes/insight'
import debugLog from 'src/javascripts/debugLog'
import BigNumber from 'bignumber.js'
import caValidator from 'wallet-address-validator'
import TrezorConnect from 'trezor-connect'
import helpers from 'networks/helpers/utils'

const transferBtcCoins = async function(award) { // award in JSON
  const network = award.token.blockchain_network.replace('bitcoin_', '')
  const recipientAddress = award.account.bitcoin_wallet
  let amount = parseFloat(award.total_amount)

  if (!recipientAddress || recipientAddress === '' || amount <= 0 || !(network === 'mainnet' || network === 'testnet')) {
    return
  }
  const networkType = network === 'mainnet' ? 'prod' : 'testnet'
  const addressValid = caValidator.validate(recipientAddress, 'BTC', networkType)
  let txHash
  try {
    if (addressValid) {
      alert( 'Waiting...')
      txHash = await submitTransaction(network, recipientAddress, amount)
    }
  } catch (err) {
    console.log(err)
    alert( err.message || 'The transaction failed')
    helpers.showMessageWhenTransactionFailed(award)
  }
  if (txHash) {
    const sub = network === 'mainnet' ? 'btc' : 'btc-testnet'
    const link = `https://live.blockcypher.com/${sub}/tx/${txHash}`
    helpers.updateTransactionAddress(award, txHash, link)
  }
  return txHash
}

// amount in BTC
// network: 'mainnet' or 'testnet'
const submitTransaction = async function(network, to, amount) {
  const coinType = network === 'mainnet' ? 2147483648 : 2147483649
  const addressN = [2147483697, coinType, 2147483648, 0, 0]
  const coinName = network === 'mainnet' ? 'Bitcoin' : 'Testnet'
  const fee = await utils.getFee()
  debugLog(`fee : ${fee}`)

  const fromAddress = await getFirstBitcoinAddress(network, false)
  const account = await insight.getInfo(fromAddress, network)
  debugLog(account)
  if (amount + fee >= account.balance) {
    const sub = network === 'mainnet' ? 'btc' : 'btc-testnet'
    const link = `https://live.blockcypher.com/${sub}/address/${fromAddress}`
    throw Error(`Account <a href='${link}' target='_blank'>${fromAddress}</a> <br> You don't have sufficient Tokens to send`)
  }
  const utxoList = await insight.getUtxoList(fromAddress, network)
  const amountSat = new BigNumber(amount).times(1e8)
  const feeSat = new BigNumber(fee).times(1e8)
  const selectUtxo = utils.selectTxs(utxoList, amount, fee)
  debugLog('selectUtxo .........')
  debugLog(selectUtxo)
  let inputs = []
  let totalSelectSat = new BigNumber(0)
  for (let i = 0; i < selectUtxo.length; i++) {
    const item = selectUtxo[i]
    debugLog('item ............. ' + i)
    totalSelectSat = totalSelectSat.plus(item.satoshis)
    inputs.push({
      address_n  : addressN,
      prev_index : item.pos,
      prev_hash  : item.hash,
      amount     : `${item.satoshis}`,
      script_type: 'SPENDP2SHWITNESS'
    })
  }
  const changeSat = totalSelectSat.minus(amountSat).minus(feeSat)
  const outputs = [
    {
      address_n  : addressN,
      amount     : changeSat.toString(),
      script_type: 'PAYTOP2SHWITNESS'
    }, {
      address    : to,
      amount     : amountSat.toString(),
      script_type: 'PAYTOADDRESS'
    }
  ]
  debugLog('inputs :')
  debugLog(inputs)
  debugLog('outputs :')
  debugLog(outputs)
  const rs = await TrezorConnect.signTransaction({inputs: inputs, outputs: outputs, coin: coinName, push: true})
  debugLog(rs)
  if (rs.success) {
    return rs.payload.txid
  } else if (rs.payload.error) {
    throw Error(rs.payload.error)
  }
}

// network: 'mainnet' or 'testnet'
const getFirstBitcoinAddress = async function(network, isLegacy) {
  const purpose = isLegacy ? 44 : 49
  let path, coinName
  switch (network) {
    case 'testnet':
      path = `m/${purpose}'/1'/0'/0/0`
      coinName = 'test'
      break
    case 'mainnet':
      path = `m/${purpose}'/0'/0'/0/0`
      coinName = 'btc'
      break
    default:
  }
  const rs = await TrezorConnect.getAddress({
    path: path,
    coin: coinName
  })
  return rs.payload.address
}

export default { transferBtcCoins, getFirstBitcoinAddress, submitTransaction }

/* eslint-disable no-alert, no-undef, complexity, standard/object-curly-even-spacing, default-case */

window.bitcoinTrezor = (function() {
  const BigNumber = require('bignumber.js')
  const insight = require('networks/bitcoin/nodes/insight').default
  const utils = require('networks/bitcoin/helpers/utils')
  const debugLog = require('src/javascripts/debugLog')
  const caValidator = require('crypto-address-validator')

  transferBtcCoins = async function(award) { // award in JSON
    const network = award.project.blockchain_network.replace('bitcoin_', '')
    const recipientAddress = award.account.bitcoin_wallet
    let amount = parseFloat(award.total_amount)
    if (!recipientAddress || recipientAddress === '' || amount <= 0 || !(network === 'mainnet' || network === 'testnet')) {
      return
    }
    const networkType = network === 'mainnet' ? 'prod' : 'testnet'
    const addressValid = caValidator.validate(recipientAddress, 'BTC', networkType)
    try {
      if (addressValid) {
        alertMsg($('#metamaskModal1'), 'Waiting...')
        const txHash = await submitTransaction(network, recipientAddress, amount)
        debugLog('transaction address: ' + txHash)
        if (txHash) {
          $.post('/projects/' + award.project.id + '/awards/' + award.id + '/update_transaction_address', { tx: txHash })
        }
        $('#metamaskModal1').foundation('close')
      }
    } catch (err) {
      console.log(err)
      if (err.name === 'ErrorMessage') {
        alertMsg($('#metamaskModal1'), err.message)
      } else {
        $('#metamaskModal1').foundation('close')
      }
      if ($('body.projects-show').length > 0) {
        $('.flash-msg').html('The tokens have been awarded but not transferred. You can transfer tokens on the blockchain on the <a href="/projects/' + award.project.id + '/awards">awards</a> page.')
      }
      return
    }
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
      const e = new Error("You don't have sufficient Tokens to send")
      e.name = 'ErrorMessage'
      throw e
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
    }
  }

  // network: 'mainnet' or 'testnet'
  getFirstBitcoinAddress = async function(network, isLegacy) {
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
    }
    const rs = await TrezorConnect.getAddress({
      path: path,
      coin: coinName
    })
    return rs.payload.address
  }

  return {
    transferBtcCoins
  }
})()

/* eslint-disable no-alert, no-undef, complexity, standard/object-curly-even-spacing, default-case */

window.cardano = (function() {
  const {ADALITE_CONFIG} = require('networks/cardano/trezor/config')
  const derivationSchemes = require('networks/cardano/trezor/wallet/derivation-schemes')
  const Cardano = require('networks/cardano/trezor/wallet/cardano-wallet')
  const {
    sendAddressValidator,
    sendAmountValidator,
  } = require('networks/cardano/trezor/helpers/validators')
  const BlockchainExplorer = require('networks/cardano/trezor/wallet/blockchain-explorer')

  test4 = async function() {
    ad = sendAddressValidator('De2tdPwUPEZC8obLcka73T3g7WNhb5x1563KdgQyDenoeLbaP9LjHNwsCLa')
    console.log(ad)
    console.log(ad.validationError)
    if (ad.validationError) {
      console.log(ad.validationError.code)
    }
    console.log(11111111111)
    address = 'Ae2tdPwUPEZC8obLcka73T3g7WNhb5x1563KdgQyDenoeLbaP9LjHNwsCLa'
    amount = 0.1
    coin = sendAmountValidator('-1')
    console.log(coin)
    if (coin.validationError) {
      console.log(coin.validationError.code)
    }
    coins = sendAmountValidator(`${amount}`).coins
    const rs = await submitTransaction(address, coins)
    console.log('rs tx ---------------')
    console.log(rs)
  }

  const submitTransaction = async(address, amount) => {
    let wallet = null

    wallet = await Cardano.CardanoWallet({
      cryptoProvider  : 'trezor',
      config          : ADALITE_CONFIG,
      network         : 'mainnet',
      derivationScheme: derivationSchemes.v2,
    })
    try {
      const signedTx = await wallet.prepareSignedTx(address, amount)
      const txSubmitResult = await wallet.submitTx(signedTx)
      console.log(txSubmitResult)
      if (!txSubmitResult) {
        console.log(txSubmitResult)
        throw Error('TransactionRejectedByNetwork')
      }
      return txSubmitResult.txHash
    } catch (e) {
      console.log(e)
    }
  }

  test = async function() {
    signed = '82839f8200d81858248258201af8fa0b754ff99253d983894e63a2b09cbb56c833ba18c3384210163f63dcfc00ff9f8282d818582183581c9e1c71de652ec8b85fec296f0685ca3988781c94a2e1a5d89d92f45fa0001a0d0c25611a002dd2e88282d818582183581c39ad4aec46332f88f45088c06d36cc8a0340e106bd07a9424281fe1ba0001ab1c1efbe1a006ca793ffa0818200d818588582584059781a5b4fa6c8fffaf9761483cfa18cdf890aaaa178aef03cb8565a55c0493959835e85418c318cd55c8b42a3b7784a170c1cc9d3ce67c3631bd75cb35d736e58409bb23a358021eb4f5adeb40541820c957c34c3161a429f36b53c005e4731ecf24bf5792ccec000b27c87ab7b0a9459635cc022df32004c01fd06cc1359c55d07'
    rs = await submitTx(signed)
    console.log('------------------a')
    console.log(rs)
    console.log('------------------b')
  }

  submitTx = async function(signedTx) {
    // const blockchainExplorer = BlockchainExplorer(config, state)
    const blockchainExplorer = BlockchainExplorer()
    const {txBody, txHash} = {txBody: signedTx, txHash: '1af8fa0b754ff99253d983894e63a2b09cbb56c833ba18c3384210163f63dcfc'}
    console.log(txBody)
    console.log(txHash)

    const response = await blockchainExplorer.submitTxRaw(txHash, txBody).catch((e) => {
      // debugLog(e)
      console.log(e)
      throw NamedError('TransactionRejectedByNetwork')
    })
    console.log(response)

    console.log(txBody)
    console.log(txHash)
    // TODO: refactor signing process so we dont need to reparse signed transaction for this
    // const {txAux} = parseTx(Buffer.from(txBody, 'hex'))
    // console.log(txAux)
    // await updateUtxosFromTxAux(txAux)

    // return response
  }

  return {
    test, test4
  }
})()

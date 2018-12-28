/* eslint-disable no-alert, no-undef, complexity, standard/object-curly-even-spacing, default-case */

window.cardano = (function() {
  const {ADALITE_CONFIG} = require('networks/cardano/trezor/config')
  const derivationSchemes = require('networks/cardano/trezor/wallet/derivation-schemes')
  const Cardano = require('networks/cardano/trezor/wallet/cardano-wallet')
  const {
    sendAddressValidator,
    sendAmountValidator,
  } = require('networks/cardano/trezor/helpers/validators')

  transferAdaCoins = async function(award) { // award in JSON
    const network = award.project.blockchain_network.replace('cardano_', '')
    const recipientAddress = award.account.cardano_wallet
    let amount = award.total_amount
    if (!recipientAddress || recipientAddress === '' || amount <= 0 || !(network === 'mainnet' || network === 'testnet')) {
      return
    }
    amount = 0.1
    const addressValidator = sendAddressValidator(recipientAddress)
    const coins = sendAmountValidator(`${amount}`).coins
    try {
      if (!addressValidator.validationError && !coins.validationError) {
        const txHash = await submitTransaction(network, recipientAddress, coins)
        console.log('transaction address: ' + txHash)
        if (txHash) {
          $.post('/projects/' + award.project.id + '/awards/' + award.id + '/update_transaction_address', { tx: txHash })
        }
      }
    } catch (err) {
      if ($('body.projects-show').length > 0) {
        $('.flash-msg').html('The tokens have been awarded but not transferred. You can transfer tokens on the blockchain on the <a href="/projects/' + award.project.id + '/awards">awards</a> page.')
      }
      return
    }
  }

  // network: 'mainnet'
  const submitTransaction = async function(network, address, amount) {
    const wallet = await Cardano.CardanoWallet({
      cryptoProvider  : 'trezor',
      config          : ADALITE_CONFIG,
      network         : network,
      derivationScheme: derivationSchemes.v2,
    })
    try {
      const signedTx = await wallet.prepareSignedTx(address, amount)
      const txSubmitResult = await wallet.submitTx(signedTx)
      console.log(txSubmitResult)
      if (!txSubmitResult) {
        throw Error('TransactionRejectedByNetwork')
      }
      return txSubmitResult.txHash
    } catch (e) {
      console.log(e)
      throw Error('TransactionRejected')
    }
  }

  return {
    transferAdaCoins
  }
})()

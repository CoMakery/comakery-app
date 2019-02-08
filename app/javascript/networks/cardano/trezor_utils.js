import jQuery from 'jquery'
import debugLog from 'src/javascripts/debugLog'
import {ADALITE_CONFIG} from 'networks/cardano/trezor/config'
import derivationSchemes from 'networks/cardano/trezor/wallet/derivation-schemes'
import Cardano from 'networks/cardano/trezor/wallet/cardano-wallet'
import {
  sendAddressValidator,
  sendAmountValidator,
} from 'networks/cardano/trezor/helpers/validators'

const transferAdaCoins = async function(award) { // award in JSON
  const network = award.project.blockchain_network.replace('cardano_', '')
  const recipientAddress = award.account.cardano_wallet
  let amount = parseFloat(award.total_amount)

  if (!recipientAddress || recipientAddress === '' || amount <= 0 || !(network === 'mainnet' || network === 'testnet')) {
    return
  }
  const addressValidator = sendAddressValidator(recipientAddress)
  const coins = sendAmountValidator(`${amount}`).coins
  try {
    if (!addressValidator.validationError && !coins.validationError) {
      window.alertMsg('#metamaskModal1', 'Waiting...')
      const txHash = await submitTransaction(network, recipientAddress, coins)
      debugLog('transaction address: ' + txHash)
      if (txHash) {
        jQuery.post('/projects/' + award.project.id + '/awards/' + award.id + '/update_transaction_address', { tx: txHash })
      }
      window.foundationCmd('#metamaskModal1', 'close')
      return txHash
    }
  } catch (err) {
    console.error(err)
    window.alertMsg('#metamaskModal1', err.message)
    if (jQuery('body.projects-show').length > 0) {
      jQuery('.flash-msg').html('The tokens have been awarded but not transferred. You can transfer tokens on the blockchain on the <a href="/projects/' + award.project.id + '/awards">awards</a> page.')
    }
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
    debugLog(txSubmitResult)
    if (!txSubmitResult) {
      throw Error('Transaction rejected by the network')
    }
    return txSubmitResult.txHash
  } catch (e) {
    if (e.name === 'InsufficientCoinsError') {
      const fromAddress = await wallet.getFirstAddress()
      const basicUrl = network === 'mainnet' ? 'https://cardanoexplorer.com' : 'https://cardano-explorer.cardano-testnet.iohkdev.io'
      const link = `${basicUrl}/address/${fromAddress}`
      const e = new Error(`Account <a href='${link}' target='_blank'>${fromAddress}</a> <br> You don't have sufficient Tokens to send`)
      e.name = 'ErrorMessage'
      throw e
    } else {
      throw Error('Transaction rejected')
    }
  }
}

export default { transferAdaCoins, submitTransaction }

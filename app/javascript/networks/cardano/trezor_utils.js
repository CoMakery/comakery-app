import debugLog from 'src/javascripts/debugLog'
import {ADALITE_CONFIG} from 'networks/cardano/trezor/config'
import derivationSchemes from 'networks/cardano/trezor/wallet/derivation-schemes'
import Cardano from 'networks/cardano/trezor/wallet/cardano-wallet'
import utils from 'networks/helpers/utils'
import {
  sendAddressValidator,
  sendAmountValidator
} from 'networks/cardano/trezor/helpers/validators'

const transferAdaCoins = async function(award) { // award in JSON
  const network = award.token.blockchain_network.replace('cardano_', '')
  const recipientAddress = award.account.cardano_wallet
  let amount = parseFloat(award.total_amount)

  if (!recipientAddress || recipientAddress === '' || amount <= 0 || !(network === 'mainnet' || network === 'testnet')) {
    return
  }
  const addressValidator = sendAddressValidator(recipientAddress)
  const coins = sendAmountValidator(`${amount}`).coins
  let txHash
  try {
    if (!addressValidator.validationError && !coins.validationError) {
      txHash = await submitTransaction(network, recipientAddress, coins)
    }
  } catch (err) {
    console.error(err)
    alert(err.message || 'The transaction failed')
    utils.showMessageWhenTransactionFailed(award)
  }
  if (txHash) {
    const basicUrl = network === 'mainnet' ? 'https://cardanoexplorer.com' : 'https://cardano-explorer.cardano-testnet.iohkdev.io'
    const link = `${basicUrl}/tx/${txHash}`
    utils.updateTransactionAddress(award, txHash, link)
  }
  return txHash
}

// network: 'mainnet'
const submitTransaction = async function(network, address, amount) {
  const wallet = await Cardano.CardanoWallet({
    cryptoProvider  : 'trezor',
    config          : ADALITE_CONFIG,
    network         : network,
    derivationScheme: derivationSchemes.v2
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
      throw Error(`Account <a href='${link}' target='_blank'>${fromAddress}</a> <br> You don't have sufficient Tokens to send`)
    } else {
      throw Error('Transaction rejected')
    }
  }
}

export default { transferAdaCoins, submitTransaction }

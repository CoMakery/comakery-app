import jQuery from 'jquery'
import debugLog from 'src/javascripts/debugLog'
import { of } from 'rxjs'
import { initializeWallet, transaction, confirmOperation } from 'tezos-wallet'

const transferXtzCoins = async function(award) { // award in JSON
  const network = award.project.blockchain_network.replace('tezos_', '')
  const recipientAddress = award.account.tezos_wallet
  let amount = parseFloat(award.total_amount)

  if (!recipientAddress || recipientAddress === '' || amount <= 0 || !(network === 'mainnet' || network === 'testnet')) {
    return
  }
  const addressValid = window.eztz.crypto.checkAddress(recipientAddress)
  try {
    if (addressValid) {
      await submitTransaction(award, network, recipientAddress, amount)
    }
  } catch (err) {
    console.error(err)
    if (err.name === 'ErrorMessage') {
      window.alertMsg('#metamaskModal1', err.message)
    } else {
      window.foundationCmd('#metamaskModal1', 'close')
    }
    showMessageWhenTransactionFailed(award)
  }
}

// amount in XTZ
// network: 'mainnet'
const submitTransaction = async function(award, network, to, amount) {
  const fee = 0.0015
  const path = "m/44'/1729'/0'"
  const model = await getTrezorModel()
  console.log('trezor model: ', model)
  if (model !== 'T') {
    throw new Error('The Trezor is not supported')
  }
  window.alertMsg('#metamaskModal1', 'Waiting...')
  const publicKey = await getPublicKey(path)
  const fromAddress = await getFirstTezosAddress(path)
  const balance = await window.eztz.rpc.getBalance(fromAddress)
  if ((amount + fee) * 1e6 >= parseFloat(balance)) {
    const link = `https://tzscan.io/${fromAddress}`
    const e = new Error(`Account <a href='${link}' target='_blank'>${fromAddress}</a> <br> You don't have sufficient Tokens to send`)
    e.name = 'ErrorMessage'
    throw e
  }
  of([]).pipe(
    initializeWallet(state => ({
      secretKey    : '',
      publicKey    : publicKey,
      publicKeyHash: fromAddress,
      node         : {
        name   : 'mainnet',
        display: 'Mainnet',
        url    : 'https://mainnet.simplestaking.com:3000',
        tzscan : {
          url: 'http://tzscan.io/',
        }
      },
      type: 'TREZOR_T',
      path: path
    })),
    // send amount to other wallet
    transaction(state => ({
      to    : to,
      amount: amount,
      fee   : fee
    })),
    confirmOperation(state => ({
      injectionOperation: state.injectionOperation,
    }))
  ).subscribe(
    state => {
      const txHash = state.confirmOperation.injectionOperation
      debugLog(['transaction succeeded', state])
      console.log('transaction address: ' + txHash)
      updateTransactionAddress(award, txHash)
    },
    error => {
      console.error('transaction failed', error)
      showMessageWhenTransactionFailed(award)
      window.foundationCmd('#metamaskModal1', 'close')
    }
  )
}

const updateTransactionAddress = function(award, txHash) {
  if (txHash) {
    jQuery.post('/projects/' + award.project.id + '/awards/' + award.id + '/update_transaction_address', { tx: txHash }, () => {
      const link = `https://tzscan.io/${txHash}`
      const alertMsg = `The <a href='${link}' target='_blank'>transaction address</a> of the award has been successfully updated`
      window.alertMsg('#metamaskModal1', alertMsg)
    })
  }
}

const showMessageWhenTransactionFailed = function(award) {
  if (jQuery('body.projects-show').length > 0) {
    jQuery('.flash-msg').html('The tokens have been awarded but not transferred. You can transfer tokens on the blockchain on the <a href="/projects/' + award.project.id + '/awards">awards</a> page.')
  }
}

const getTrezorModel = async function() {
  const {payload: features} = await window.TrezorConnect.getFeatures()
  return features.model
}

// path: eg. "m/44'/1729'/0'"
const getFirstTezosAddress = async function(path) {
  const rs = await window.TrezorConnect.tezosGetAddress({
    path        : path,
    showOnTrezor: false
  })
  return rs.payload.address
}

// path: eg. "m/44'/1729'/0'"
const getPublicKey = async function(path) {
  const rs = await window.TrezorConnect.tezosGetPublicKey({
    path: path
  })
  return rs.payload.publicKey
}

export default { transferXtzCoins, submitTransaction, getFirstTezosAddress, getTrezorModel, getPublicKey }

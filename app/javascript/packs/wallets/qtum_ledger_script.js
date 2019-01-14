/* eslint-disable no-alert, no-undef, complexity, standard/object-curly-even-spacing */

window.qtumLedger = (function() {
  const config = require('networks/qtum/config').default
  const Wallet = require('networks/qtum/ledger/wallet').default

  transferQtumCoins = async function(award) { // award in JSON
    const network = award.project.blockchain_network.replace('qtum_', '')
    const recipientAddress = award.account.qtum_wallet
    let amount = parseFloat(award.total_amount)
    if (!recipientAddress || recipientAddress === '' || amount <= 0 || !(network === 'mainnet' || network === 'testnet')) {
      return
    }
    try {
      const addressValid = true
      if (addressValid) {
        alertMsg($('#metamaskModal1'), 'Waiting...')
        const txHash = await submitTransaction(network, recipientAddress, amount)
        console.log(`transaction address: ${txHash}`)
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
    }
  }

  // amount in QTUM
  // network: 'mainnet' or 'testnet'
  const submitTransaction = async function(network, to, amount) {
    const fee = 0.001582
    config.set('network', network)
    const server = require('networks/qtum/server').default
    let path
    switch (network) {
      case 'testnet':
        path = "m/44'/1'/0'/0"
        break
      case 'mainnet':
        path = "m/44'/88'/0'/0"
        break
      default:
    }
    const ledger = await Wallet.connectLedger()
    console.log('ledger ...........')
    console.log(ledger)
    const hdNode = await Wallet.restoreHdNodeFromLedgerPath(ledger, path)

    console.log(hdNode)
    let wallet
    Wallet.restoreFromHdNodeByPage(hdNode, 0, 1).forEach((item) => {
      console.log('item ...........')
      wallet = item.wallet
    })
    console.log(wallet)
    const serializedTx = await wallet.generateTx(to, amount, fee)
    if (serializedTx) {
      const txId = await server.currentNode().sendRawTx(serializedTx)
      console.log('txId =' + txId)
      return txId
    }
  }

  return {
    transferQtumCoins
  }
})()

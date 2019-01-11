/* eslint-disable no-alert, no-undef, complexity, standard/object-curly-even-spacing */

const Wallet = require('networks/qtum/ledger/wallet').default

window.qtumLedger = (function() {
  transferQtumCoins = async function(award) { // award in JSON
    const network = award.project.blockchain_network.replace('qtum_', '')
    const recipientAddress = award.account.qtum_wallet
    let amount = award.total_amount
    if (!recipientAddress || recipientAddress === '' || amount <= 0 || !(network === 'mainnet' || network === 'testnet')) {
      return
    }
    submitTransaction(network, recipientAddress, amount)
  }
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
    Wallet.restoreFromHdNodeByPage(hdNode, start, 1).forEach((item) => {
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

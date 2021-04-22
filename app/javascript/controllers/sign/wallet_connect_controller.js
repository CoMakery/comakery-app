import { Controller } from 'stimulus'
import { HelpersEthereum } from "@open-rights-exchange/chainjs"
import WalletConnect from "@walletconnect/client"
import QRCodeModal from "@walletconnect/qrcode-modal"
import { FLASH_ADD_MESSAGE } from '../../src/javascripts/eventTypes'
import PubSub from 'pubsub-js'

export default class extends Controller {
  static targets = [ "walletAddress", "txButtons" ]

  async walletConnectInit() {
    const bridge = "https://bridge.walletconnect.org"
    const connector = new WalletConnect({ bridge, qrcodeModal: QRCodeModal })
    this.connector = connector

    if (!connector.connected) {
      await connector.createSession()
    }

    connector.on("connect", this.onWalletConnect.bind(this))
    connector.on("session_update", this.onWalletUpdate.bind(this))
    connector.on("disconnect", this.onWalletDisconnect.bind(this))

    if (connector.connected) {
      const { chainId, accounts } = connector
      this.onSessionUpdate(accounts, chainId)
    }
  }

  onWalletConnect(error, payload) {
    if (error) {
      throw error;
    }
  
    const { accounts, chainId } = payload.params[0]
    this.onSessionUpdate(accounts, chainId)
  }

  onWalletUpdate(error, payload) {
    if (error) {
      throw error;
    }
  
    const { accounts, chainId } = payload.params[0]
    this.onSessionUpdate(accounts, chainId)
  }

  onWalletDisconnect(error, payload) {
    if (error) {
      throw error;
    }
  
    const { accounts, chainId } = payload.params[0]
    this.onSessionUpdate(accounts, chainId)
    this._connector = null
  }

  onSessionUpdate(accounts, chainId) {
    this.accounts = accounts
    this.chainId = chainId
    this.updateTargets()
  }
  
  updateTargets() {
    this.walletAddressTarget.textContent = this.accounts ? this.accounts[0] : 'Disconnected'
    
    this.txButtonsTargets.forEach(button => {
      if (this.connector && this.connector.connected) {
        button.classList.add('transfer-tokens-btn__enabled')
      } else {
        button.classList.remove('transfer-tokens-btn__enabled')
      }
    })
  }

  switch(e) {
    e.preventDefault()

    if (this.connector && this.connector.connected && this.accounts) {
      this.connector.killSession()
      this.connector = null
    } else {
      this.walletConnectInit()
    }
  }

  async sendTx(e) {
    e.preventDefault()

    const button = e.target.closest("a")
    button.classList.remove('transfer-tokens-btn__enabled')
    
    const txNewUrl = button.dataset.txNewUrl
    const txReceiveUrl = button.dataset.txReceiveUrl
    const response = await fetch(`${txNewUrl}&source=${this.accounts[0]}`)
    const responseJSON = await response.json()
    const tx = JSON.parse(responseJSON.tx)
    const state = responseJSON.state
    
    tx.data = HelpersEthereum.generateDataFromContractAction(tx.contract)
    delete tx.contract

    this.connector
      .sendTransaction(tx)
      .then(async (txHash) => {
        await fetch(`${txReceiveUrl}?state=${state}&transaction_id=${txHash}`)
      })
      .catch(async (error) => {
        console.error(error)
        PubSub.publish(FLASH_ADD_MESSAGE, { severity: "error", text: error })
        await fetch(`${txReceiveUrl}?state=${state}&error_message=${error}`)
      })
  }
}
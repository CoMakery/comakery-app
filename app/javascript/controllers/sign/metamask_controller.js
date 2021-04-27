import { Controller } from 'stimulus'
import { HelpersEthereum } from "@open-rights-exchange/chainjs"
import MetaMaskOnboarding from '@metamask/onboarding'
import { FLASH_ADD_MESSAGE } from '../../src/javascripts/eventTypes'
import PubSub from 'pubsub-js'

export default class extends Controller {
  static targets = [ "walletAddress", "txButtons", "connectButton", "otherConnectButtons" ]

  async metamaskInit() {
    const onboarding = new MetaMaskOnboarding()
    this.onboarding = onboarding

    if (MetaMaskOnboarding.isMetaMaskInstalled()) {
      window.ethereum.on('accountsChanged', this.onAccountsUpdate.bind(this))
      this.onAccountsUpdate(await window.ethereum.request({
        method: 'eth_requestAccounts',
      }))
    } else {
      onboarding.startOnboarding()
    }
  }

  onAccountsUpdate(accounts) {
    this.accounts = accounts
    this.updateTargets()
  }

  updateTargets() {
    this.walletAddressTarget.textContent = this.accountsPresent() ? this.accounts[0] : 'Disconnected'
    
    if (this.accountsPresent()) {
      this.connectButtonTarget.classList.add('wallet-connect--button__connected')
    } else {
      this.connectButtonTarget.classList.remove('wallet-connect--button__connected')
    }

    this.otherConnectButtonsTargets.forEach(button => {
      if (this.accountsPresent()) {
        button.classList.add('wallet-connect--button__disabled')
      } else {
        button.classList.remove('wallet-connect--button__disabled')
      }
    })
    
    this.txButtonsTargets.forEach(button => {
      if (this.accountsPresent()) {
        button.classList.add('transfer-tokens-btn__enabled')
      } else {
        button.classList.remove('transfer-tokens-btn__enabled')
      }
    })
  }

  accountsPresent() {
    return this.accounts && this.accounts > 0
  }

  switch(e) {
    e.preventDefault()

    if (this.accountsPresent()) {
      this.onboarding.stopOnboarding()
      this.onboarding = null
      this.accounts = null
      this.updateTargets()
    } else {
      this.metamaskInit()
    }
  }

  async sendTx(e) {
    if (!this.accounts) {
      return
    }

    e.preventDefault()

    const button = e.target.closest("a")
    button.classList.remove('transfer-tokens-btn__enabled')
    
    let dataset
    
    if (button.dataset.txNewUrl && button.dataset.txReceiveUrl) {
      dataset = button.dataset
    } else {
      dataset = await this.saveTransactable(e)
    }

    const txNewUrl = dataset.txNewUrl
    const txReceiveUrl = dataset.txReceiveUrl
    const response = await fetch(`${txNewUrl}&source=${this.accounts[0]}`)
    const responseJSON = await response.json()
    const tx = JSON.parse(responseJSON.tx)
    const state = responseJSON.state
    
    if (tx.contract) {
      tx.data = HelpersEthereum.generateDataFromContractAction(tx.contract)
      delete tx.contract
    }

    window.ethereum
      .request({
        method: 'eth_sendTransaction',
        params: [tx],
      })
      .then(async (txHash) => {
        await fetch(`${txReceiveUrl}?state=${state}&transaction_id=${txHash}`)
      })
      .catch(async (error) => {
        console.error(error.message)
        PubSub.publish(FLASH_ADD_MESSAGE, { severity: "error", text: error.message })
        await fetch(`${txReceiveUrl}?state=${state}&error_message=${error.message}`)
      })
  }

  async saveTransactable(e) {
    const form = e.target.closest("form")

    const response = await fetch(
      form.action,
      {
        body: new FormData(form),
        method: form.method,
        headers: {
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        }
      }
    )

    return await response.json()
  }
}
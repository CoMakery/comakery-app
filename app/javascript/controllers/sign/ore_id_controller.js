import { Controller } from 'stimulus'
import { Turbo } from '@hotwired/turbo-rails'

export default class extends Controller {
  static targets = [ "walletAddress", "txButtons", "connectButton", "otherConnectButtons" ]

  static values = {
    address: String,
    linkUrl: String
  }

  initialize() {
    this.name = 'ore-id'
  }

  async oreidInit() {
    if (this.addressValue) {
      this.accounts = [this.addressValue]
      this.updateTargets()
    } else {
      Turbo.visit(this.linkUrlValue)
    }
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
        button.dataset.connectedController = this.name
      } else {
        button.classList.remove('transfer-tokens-btn__enabled')
        button.dataset.connectedController = null
      }
    })
  }

  accountsPresent() {
    return this.accounts && this.accounts.length > 0
  }

  switch(e) {
    e.preventDefault()

    if (this.accountsPresent()) {
      this.accounts = null
      this.updateTargets()
    } else {
      this.oreidInit()
    }
  }

  async sendTx(e) {
    if (!this.accountsPresent()) {
      return
    }

    e.preventDefault()

    const button = e.target.closest("a")

    if (button.dataset.connectedController !== this.name) {
      return
    }

    button.classList.remove('transfer-tokens-btn__enabled')
    
    let dataset
    
    if (button.dataset.txOreidNewUrl) {
      dataset = button.dataset
    } else {
      dataset = await this.saveTransactable(e)
    }

    const txNewUrl = dataset.txOreidNewUrl
    window.open(txNewUrl)
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
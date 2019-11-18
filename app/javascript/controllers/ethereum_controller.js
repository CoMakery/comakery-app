import { Controller } from 'stimulus'
import Web3 from 'web3'
import Turbolinks from 'turbolinks'
import { fetch } from 'whatwg-fetch'

export default class extends Controller {
  static targets = [ 'button' ]

  async pay() {
    await this._initialize()

    if (this.isContract) {
      const amount = this.web3.utils.toWei(this.amount, 'wei')
      const data = this.contract.methods.transfer(this.address, amount).encodeABI()
      this._sendTransaction(this.contractAddress, null, data)
    } else {
      const amount = this.web3.utils.toWei(this.amount, 'ether')
      this._sendTransaction(this.address, amount, null)
    }
  }

  async _initialize() {
    this._disableButton()

    if (!this.isValid) {
      this._showError('Malformed Transfer. Please contact support.')
      return
    }

    await this._startDapp()
  }

  _disableButton() {
    this._buttonTargetText = this.buttonTarget.getElementsByTagName('span')[0].textContent
    this.buttonTarget.parentElement.classList.add('in-progress--metamask')
    this.buttonTarget.getElementsByTagName('span')[0].textContent = 'pending'
  }

  _enableButton() {
    this.buttonTarget.getElementsByTagName('span')[0].textContent = this._buttonTargetText
    this.buttonTarget.parentElement.classList.remove('in-progress--metamask')
    this.buttonTarget.parentElement.classList.remove('in-progress--metamask__paid')
  }

  _markButtonAsPaid() {
    this.buttonTarget.parentElement.classList.add('in-progress--metamask__paid')
    this.buttonTarget.getElementsByTagName('span')[0].textContent = 'syncing'
  }

  _sendTransaction(to, value, data) {
    this.web3.eth.sendTransaction({
      from    : this.coinBase,
      to      : to,
      value   : value,
      data    : data,
      gasPrice: this.gasPrice
    })
      .once('transactionHash', (transactionHash) => {
        this._submitTransaction(transactionHash)
        this._markButtonAsPaid()
      })
      .once('receipt', (receipt) => {
        this._submitReceipt(receipt)
      })
      .on('confirmation', (confNumber, receipt) => {
        this._submitConfirmation(confNumber)
        this._submitReceipt(receipt)
      })
      .on('error', (error) => {
        this._submitError(error)
        this._showError(error.message)
      })
      .then((receipt) => {
        this._submitReceipt(receipt)
        this._reload()
      })
  }

  _submitTransaction(transactionHash) {
    this._submitToBackend(this.updateTransactionPath, {tx: transactionHash})
  }

  _submitReceipt(receipt) {
    this._submitToBackend(this.updateTransactionPath, {receipt: receipt})
  }

  _submitConfirmation(_confNumber) {
    // do nothing
  }

  _submitError(error) {
    this._submitToBackend(this.updateTransactionPath, {error: error.message})
  }

  _submitToBackend(path, body) {
    fetch(this.updateTransactionPath, {
      credentials: 'same-origin',
      method     : 'POST',
      body       : JSON.stringify(body),
      headers    : {
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.status === 200) {
        this._showNotice(`Processed: ${JSON.stringify(body)}`)
      } else {
        this._showError('Unable to Submit Data. Please contact support.')
      }
    })
  }

  _showError(text) {
    // eslint-disable-next-line no-alert
    alert(`Error: ${text}`)
  }

  _showNotice(text) {
    console.log(`Notice: ${text}`)
  }

  _reload() {
    Turbolinks.visit(window.location.toString())
  }

  // TODO: Following Metamask initialization deprecates in mid January 2020
  //
  // https://metamask.github.io/metamask-docs/API_Reference/Ethereum_Provider#new-api
  // https://gist.github.com/rekmarks/d318677c8fc89e5f7a2f526e00a0768a
  async _startDapp() {
    if (typeof window.ethereum === 'undefined') {
      this._showError('You need a Dapp browser to proceed with the payment. Consider installing MetaMask.')
      this._enableButton()
    } else {
      await window.ethereum.enable()
        .catch((reason) => {
          if (reason === 'User rejected provider access') {
            this._showError('Access Rejected. Please reload the page and try again if you want to proceed.')
          } else {
            this._showError('Ethereum Connection Failure. Please contact support.')
          }
          this._enableButton()
        })
    }
  }

  get web3() {
    if (typeof this._web3 === 'undefined') {
      this._web3 = new Web3(window.web3.currentProvider)
    }

    return this._web3
  }

  get contract() {
    if (typeof this._contract === 'undefined') {
      this._contract = new this.web3.eth.Contract(this.contractAbi, this.contractAddress)
    }

    return this._contract
  }

  get isValid() {
    if (!this.address) {
      return false
    }

    if (!this.amount) {
      return false
    }

    if (this.isContract && !this.contractAddress) {
      return false
    }

    if (this.isContract && !this.contractAbi) {
      return false
    }

    return true
  }

  get isContract() {
    return (this.paymentType !== 'eth')
  }

  get paymentType() {
    return this.data.get('paymentType')
  }

  get address() {
    return this.data.get('address')
  }

  get amount() {
    return this.data.get('amount')
  }

  get contractAddress() {
    return this.data.get('contractAddress')
  }

  get contractAbi() {
    return JSON.parse(this.data.get('contractAbi'))
  }

  get updateTransactionPath() {
    return this.data.get('updateTransactionPath')
  }

  get gasPrice() {
    return this.web3.utils.toWei('1', 'gwei')
  }

  // TODO: Following Metamask call deprecates in mid January 2020
  get coinBase() {
    return window.web3.currentProvider.selectedAddress
  }
}

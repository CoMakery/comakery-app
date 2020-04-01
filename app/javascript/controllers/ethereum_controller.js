import { Controller } from 'stimulus'
import Web3 from 'web3'
import Turbolinks from 'turbolinks'
import { fetch } from 'whatwg-fetch'

export default class extends Controller {
  static targets = [ 'button' ]

  async pay() {
    await this._initialize()

    this._createTransaction()
  }

  async _initialize() {
    this._markButtonAsCreating()

    if (!this.isValid) {
      this._showError('Malformed Transfer. Please contact support.')
      return
    }

    await this._startDapp()
  }

  _markButtonAsCreating() {
    this._buttonTargetText = this.buttonTarget.getElementsByTagName('span')[0].textContent
    this.buttonTarget.parentElement.classList.add('in-progress--metamask')
    this.buttonTarget.getElementsByTagName('span')[0].textContent = 'creating'
  }

  _markButtonAsReady() {
    this.buttonTarget.getElementsByTagName('span')[0].textContent = this._buttonTargetText
    this.buttonTarget.parentElement.classList.remove('in-progress--metamask')
    this.buttonTarget.parentElement.classList.remove('in-progress--metamask__created')
    this.buttonTarget.parentElement.classList.remove('in-progress--metamask__paid')
  }

  _markButtonAsCreated() {
    this.buttonTarget.parentElement.classList.add('in-progress--metamask__created')
    this.buttonTarget.getElementsByTagName('span')[0].textContent = 'created'
  }

  _markButtonAsPending() {
    this.buttonTarget.parentElement.classList.add('in-progress--metamask__paid')
    this.buttonTarget.getElementsByTagName('span')[0].textContent = 'processing'
  }

  _createTransaction() {
    fetch(this.transactionsPath, {
      credentials: 'same-origin',
      method     : 'POST',
      body       : JSON.stringify({
        body: {
          data: {
            transaction: {
              'award_id': this.id,
              'source'  : this.coinBase
            }
          }
        }
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.status === 201) {
        response.json().then(r => {
          this.data.set('transactionId', r.id)
          this.data.set('address', r.destination)
          this.data.set('amount', r.amount)
          this.data.set('contractAddress', r.contractAddress)
          this.data.set('network', r.network)
        })

        if (this.isContract) {
          const data = this.contract.methods.transfer(this.address, this.amount).encodeABI()
          this._sendTransaction(this.contractAddress, null, data)
        } else {
          this._sendTransaction(this.address, this.amount, null)
        }

        this._markButtonAsCreated()
      } else if (response.status === 204) {
        this._showError('Transfer is already being processed.')
      } else {
        this._showError('Unable to create transaction. Please contact support.')
      }
    })
  }

  _submitTransaction(hash) {
    fetch(this.transactionsPath + '/' + this.transactionId, {
      credentials: 'same-origin',
      method     : 'PATCH',
      body       : JSON.stringify({
        body: {
          data: {
            transaction: {
              'tx_hash': hash
            }
          }
        }
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.status === 200) {
        this._markButtonAsPending()
      } else {
        this._showError('Unable to submit transaction. Please contact support.')
      }
    })
  }

  _cancelTransaction(message) {
    fetch(this.transactionsPath + '/' + this.transactionId, {
      credentials: 'same-origin',
      method     : 'DELETE',
      body       : JSON.stringify({
        body: {
          data: {
            transaction: {
              'status_message': message,
              'tx_hash'       : this.hash
            }
          }
        }
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.status === 200) {
        this._markButtonAsReady()
      } else {
        this._showError('Unable to cancel transaction. Please contact support.')
      }
    })
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
        this.data.set('hash', transactionHash)
        this._submitTransaction(transactionHash)
      })
      .once('receipt', (receipt) => {
        this._submitReceipt(receipt)
      })
      .on('confirmation', (confNumber, receipt) => {
        this._submitConfirmation(confNumber)
        this._submitReceipt(receipt)
      })
      .on('error', (error) => {
        this._cancelTransaction('Cancelled by Metamask')
        this._showError(error.message)
      })
  }

  _submitReceipt(_receipt) {
    // do nothing
  }

  _submitConfirmation(_confNumber) {
    // do nothing
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

  // TODO: Following Metamask initialization deprecates in Q2 2020
  //
  // https://metamask.github.io/metamask-docs/API_Reference/Ethereum_Provider#new-api
  // https://gist.github.com/rekmarks/d318677c8fc89e5f7a2f526e00a0768a
  async _startDapp() {
    if (typeof window.ethereum === 'undefined') {
      this._showError('You need a Dapp browser to proceed with the transaction. Consider installing MetaMask.')
      this._markButtonAsReady()
    } else {
      await window.ethereum.enable()
        .catch((reason) => {
          if (reason === 'User rejected provider access') {
            this._showError('Access rejected. Please reload the page and try again if you want to proceed.')
          } else {
            this._showError('Ethereum connection failure. Please contact support.')
          }
          this._markButtonAsReady()
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

  get id() {
    return this.data.get('id')
  }

  get hash() {
    return this.data.get('hash')
  }

  get transactionId() {
    return this.data.get('transactionId')
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

  get transactionsPath() {
    return this.data.get('transactionsPath')
  }

  get gasPrice() {
    return this.web3.utils.toWei('1', 'gwei')
  }

  // TODO: Following Metamask call deprecates in Q2 2020
  get coinBase() {
    return window.web3.currentProvider.selectedAddress
  }
}

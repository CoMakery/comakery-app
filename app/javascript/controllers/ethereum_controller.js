import { Controller } from 'stimulus'
import Web3 from 'web3'
import { Turbo } from '@hotwired/turbo-rails'
import { fetch } from 'whatwg-fetch'
import { Decimal } from 'decimal.js'
import { bufferToHex } from 'ethereumjs-util'

export default class extends Controller {
  static targets = [ 'button' ]

  async pay() {
    await this._initialize()

    this._createTransaction()
  }

  async mint() {
    await this._initialize()

    this._createTransaction('mint')
  }

  async burn() {
    await this._initialize()

    this._createTransaction('burn')
  }

  async _initialize() {
    this._markButtonAsCreating()

    if (!this.isValid) {
      this._showError('Malformed Transfer. Please contact support.')
      return
    }

    await this._startDapp()
  }

  async _personalSign(text, func) {
    let msg = bufferToHex(new Buffer(text, 'utf8'))
    let from = this.coinBase
    let params = [msg, from]
    let method = 'personal_sign'

    window.ethereum.sendAsync({
      method,
      params,
      from
    }, (err, response) => {
      if (err) {
        this._showError(err)
        return false
      }

      if (response.error) {
        this._showError(response.error)
        return false
      }

      func(response.result)
    })
  }

  _markButtonAsCreating() {
    this.buttonTarget.parentElement.classList.add('in-progress--metamask')
    this.buttonTarget.getElementsByTagName('span')[0].textContent = 'creating'
  }

  _markButtonAsReady() {
    this.buttonTarget.getElementsByTagName('span')[0].textContent = 'retry'
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

  _createTransaction(transactionType = 'transfer') {
    fetch(this.transactionsPath, {
      credentials: 'same-origin',
      method     : 'POST',
      body       : JSON.stringify({
        body: {
          data: {
            'blockchain_transactable_id': this.id,
            transaction                 : {
              'source': this.coinBase
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
          let data = null
          switch (transactionType) {
            case 'mint':
              data = this.contract.methods.mint(this.address, this.amount).encodeABI()
              break
            case 'burn':
              data = this.contract.methods.burn(this.address, this.amount).encodeABI()
              break
            default:
              data = this.contract.methods.transfer(this.address, this.amount).encodeABI()
          }
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
      .on('confirmation', (confNumber, _receipt) => {
        this._submitConfirmation(confNumber)
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
    Turbo.visit(window.location.toString())
  }

  // TODO: Following Metamask initialization deprecates in 2020
  //
  // https://gist.github.com/rekmarks/d318677c8fc89e5f7a2f526e00a0768a
  // https://docs.metamask.io/guide/ethereum-provider.html#methods-new-api
  async _startDapp() {
    if (typeof window.ethereum === 'undefined') {
      this._showError('You need a Dapp browser to proceed with the transaction. Consider installing MetaMask.')
      this._markButtonAsReady()
    } else {
      await window.ethereum.enable()
        .then((accounts) => {
          this.data.set('coinBase', accounts[0])
        })
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

  forceInputPrecision(event) {
    event.target.value = new Decimal(event.target.value).toDecimalPlaces(this.decimalPlaces, Decimal.ROUND_DOWN).toString()
  }

  _convertToBaseUnit(amount) {
    return Decimal.mul(Decimal.pow(10, this.decimalPlaces), new Decimal(amount)).toFixed()
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

  get decimalPlaces() {
    return new Decimal(this.data.get('decimalPlaces')).toNumber()
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

  get coinBase() {
    return this.data.get('coinBase')
  }
}

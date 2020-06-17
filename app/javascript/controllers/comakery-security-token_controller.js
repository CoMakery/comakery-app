import EthereumController from './ethereum_controller'

export default class extends EthereumController {
  _createTransaction(transactionType) {
    fetch(this.transactionsPath, {
      credentials: 'same-origin',
      method     : 'POST',
      body       : JSON.stringify({
        body: {
          data: {
            'blockchain_transactable_id'  : this.id,
            'blockchain_transactable_type': this.type,
            transaction                   : {
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
          this.data.set('contractAddress', r.contractAddress)
          this.data.set('network', r.network)
        })

        let data = null

        switch (transactionType) {
          case 'setAddressPermissions':
            data = this.contract.methods.setAddressPermissions(
              this.address,
              this.addressGroupId,
              this.addressLockupUntil,
              this._convertToBaseUnit(this.addressMaxBalance),
              this.addressFrozen
            ).encodeABI()
            break
          case 'setAllowGroupTransfer':
            data = this.contract.methods.setAllowGroupTransfer(
              this.ruleFromGroupBlockchainId,
              this.ruleToGroupBlockchainId,
              this.ruleLockupUntil
            ).encodeABI()
            break
          default:
            null
        }
        this._sendTransaction(this.contractAddress, null, data)

        this._markButtonAsCreated()
      } else if (response.status === 204) {
        this._showError('Transactable is already being processed.')
      } else {
        this._showError('Unable to create transaction. Please contact support.')
      }
    })
  }

  async pause() {
    await this._initialize()

    const data = this.contract.methods.pause().encodeABI()
    this._sendTransaction(this.contractAddress, null, data)
  }

  async unpause() {
    await this._initialize()

    const data = this.contract.methods.unpause().encodeABI()
    this._sendTransaction(this.contractAddress, null, data)
  }

  get type() {
    return this.data.get('type')
  }

  get isValid() {
    if (this.paymentType !== 'comakery') {
      return false
    }

    if (!this.contractAddress) {
      return false
    }

    if (!this.contractAbi) {
      return false
    }

    return true
  }

  get addressGroupId() {
    return this.data.get('addressGroupId')
  }

  get addressLockupUntil() {
    return this.data.get('addressLockupUntil')
  }

  get addressMaxBalance() {
    return this.data.get('addressMaxBalance')
  }

  get addressFrozen() {
    return this.data.get('addressFrozen') === 'true'
  }

  get ruleFromGroupId() {
    return this.data.get('ruleFromGroupId')
  }

  get ruleToGroupId() {
    return this.data.get('ruleToGroupId')
  }

  get ruleFromGroupBlockchainId() {
    return this.data.get('ruleFromGroupBlockchainId')
  }

  get ruleToGroupBlockchainId() {
    return this.data.get('ruleToGroupBlockchainId')
  }

  get ruleLockupUntil() {
    return this.data.get('ruleLockupUntil')
  }
}

import EthereumController from './ethereum_controller'

export default class extends EthereumController {
  async mint() {
    await this._initialize()

    const data = this.contract.methods.mint(this.address, this.amount).encodeABI()
    this._sendTransaction(this.contractAddress, null, data)
  }

  async burn() {
    await this._initialize()

    const data = this.contract.methods.burn(this.address, this.amount).encodeABI()
    this._sendTransaction(this.contractAddress, null, data)
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

  async setAddressPermissions() {
    await this._initialize()

    const data = this.contract.methods.setAddressPermissions(
      this.address,
      this.addressGroupId,
      this.addressLockupUntil,
      this.web3.utils.toHex(parseInt(this.addressMaxBalance)),
      this.addressFrozen
    ).encodeABI()

    this._sendTransaction(this.contractAddress, null, data)
  }

  async setAllowGroupTransfer() {
    await this._initialize()

    const data = this.contract.methods.setAllowGroupTransfer(
      this.ruleFromGroupId,
      this.ruleToGroupId,
      this.ruleLockupUntil
    ).encodeABI()

    this._sendTransaction(this.contractAddress, null, data)
  }

  async resetAllowGroupTransfer() {
    await this._initialize()

    const data = this.contract.methods.setAllowGroupTransfer(
      this.ruleFromGroupId,
      this.ruleToGroupId,
      0
    ).encodeABI()

    this._sendTransaction(this.contractAddress, null, data)
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

  get ruleLockupUntil() {
    return this.data.get('ruleLockupUntil')
  }
}

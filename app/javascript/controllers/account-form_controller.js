import ComakerySecurityTokenController from './comakery-security-token_controller'

export default class extends ComakerySecurityTokenController {
  static targets = [ 'form', 'button', 'inputs', 'outputs', 'addressMaxBalance', 'addressLockupUntil', 'addressGroupId', 'addressFrozen' ]

  async save() {
    if (this.setData()) {
      await this.setAddressPermissions()
    }
  }

  setData() {
    if (Number.isNaN((new Date(this.addressLockupUntilTarget.value).getTime()))) {
      this._showError('Lockup Until field is required')
      return false
    } else {
      this.data.set('addressGroupId', parseInt(this.addressGroupIdTarget.selectedOptions[0].text.match(/\((\d+)\)$/)[1] || 0))
      this.data.set('addressLockupUntil', (new Date(this.addressLockupUntilTarget.value).getTime() / 1000) || 0)
      this.data.set('addressMaxBalance', parseInt(this.addressMaxBalanceTarget.value || 0))
      this.data.set('addressFrozen', this.addressFrozenTarget.value)
      return true
    }
  }

  showForm() {
    document.querySelectorAll('.transfers-table--edit-icon__pencil').forEach(e => {
      e.classList.add('hidden')
    })

    this.outputsTargets.forEach((e) => {
      e.classList.add('hidden')
    })

    this.inputsTargets.forEach((e) => {
      e.classList.remove('hidden')
    })

    this.formTarget.classList.add('account-form--active')
  }

  hideForm() {
    document.querySelectorAll('.transfers-table--edit-icon__pencil').forEach(e => {
      e.classList.remove('hidden')
    })

    this.inputsTargets.forEach((e) => {
      e.classList.add('hidden')
    })

    this.outputsTargets.forEach((e) => {
      e.classList.remove('hidden')
    })

    this.formTarget.classList.remove('account-form--active')
  }

  _submitTransaction(_) {
    // do nothing
  }

  _submitConfirmation(_) {
    // do nothing
  }

  _submitReceipt(_) {
    this.formTarget.submit()
  }

  _submitError(_) {
    // do nothing
  }
}

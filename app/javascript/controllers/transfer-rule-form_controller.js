import ComakerySecurityTokenController from './comakery-security-token_controller'

export default class extends ComakerySecurityTokenController {
  static targets = [ 'form', 'button', 'ruleFromGroupId', 'ruleToGroupId', 'ruleLockupUntil' ]

  async create() {
    if (this._setData()) {
      await this.setAllowGroupTransfer()
    }
  }

  async delete() {
    await this.resetAllowGroupTransfer()
  }

  _setData() {
    if (Number.isNaN((new Date(this.ruleLockupUntilTarget.value).getTime()))) {
      this._showError('Allowed After Date field is required')
      return false
    } else {
      this.data.set('ruleFromGroupId', parseInt(this.ruleFromGroupIdTarget.selectedOptions[0].text.match(/\((\d+)\)$/)[1] || 0))
      this.data.set('ruleToGroupId', parseInt(this.ruleToGroupIdTarget.selectedOptions[0].text.match(/\((\d+)\)$/)[1] || 0))
      this.data.set('ruleLockupUntil', (new Date(this.ruleLockupUntilTarget.value).getTime() / 1000) || 0)
      return true
    }
  }

  showForm() {
    this.formTarget.classList.remove('hidden')
    this.formTarget.classList.add('transfer-rule-form--active')
  }

  hideForm() {
    this.formTarget.classList.add('hidden')
    this.formTarget.classList.remove('transfer-rule-form--active')
  }

  _submitTransaction(_) {
    // do nothing
  }

  _submitConfirmation(_) {
    // do nothing
  }

  _cancelTransaction(_) {
    this._markButtonAsReady()
  }

  _submitReceipt(receipt) {
    if (receipt.status) {
      this.formTarget.submit()
    }
  }

  _submitError(_) {
    // do nothing
  }
}

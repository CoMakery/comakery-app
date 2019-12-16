import ComakerySecurityTokenController from './comakery-security-token_controller'

export default class extends ComakerySecurityTokenController {
  static targets = [ 'form', 'button', 'ruleFromGroupId', 'ruleToGroupId', 'ruleLockupUntil' ]

  async create() {
    this.setData()
    await this.setAllowGroupTransfer()
  }

  async delete() {
    await this.resetAllowGroupTransfer()
  }

  setData() {
    this.data.set('ruleFromGroupId', parseInt(this.ruleFromGroupIdTarget.selectedOptions[0].text.match(/\((\d+)\)$/)[1] || 0))
    this.data.set('ruleToGroupId', parseInt(this.ruleToGroupIdTarget.selectedOptions[0].text.match(/\((\d+)\)$/)[1] || 0))
    this.data.set('ruleLockupUntil', (new Date(this.ruleLockupUntilTarget.value).getTime() / 1000) || 0)
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
    this.formTarget.submit()
  }

  _submitReceipt(_) {
    // do nothing
  }

  _submitError(_) {
    // do nothing
  }
}

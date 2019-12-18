import ComakerySecurityTokenController from './comakery-security-token_controller'

export default class extends ComakerySecurityTokenController {
  static targets = [ 'form', 'button' ]

  async pause() {
    // eslint-disable-next-line no-alert
    if (confirm('Freeze token?\n\nWARNING: All blockchain transactions will be paused.')) {
      await super.pause()
    }
  }

  async unpause() {
    // eslint-disable-next-line no-alert
    if (confirm('Unfreeze token?')) {
      await super.unpause()
    }
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

import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'form', 'button' ]

  showForm() {
    this.buttonTarget.disabled = true
    this.formTarget.classList.remove('hidden')
    this.formTarget.classList.add('transfer-rule-form--active')
  }

  hideForm() {
    this.buttonTarget.disabled = false
    this.formTarget.classList.add('hidden')
    this.formTarget.reset()
    this.formTarget.classList.remove('transfer-rule-form--active')
  }
}

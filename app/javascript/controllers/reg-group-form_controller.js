import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'form', 'create' ]

  showForm() {
    this.formTarget.style.display = 'flex'
    this.createTarget.disabled = true
  }

  hideForm() {
    this.formTarget.style.display = 'none'
    this.formTarget.reset()
    this.createTarget.disabled = false
  }
}

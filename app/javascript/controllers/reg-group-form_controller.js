import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'form', 'create' ]

  showForm() {
    this.formTarget.style.display = 'flex'
    this.createTarget.style.display = 'none'
  }

  hideForm() {
    this.formTarget.style.display = 'none'
    this.createTarget.style.display = 'block'
  }
}

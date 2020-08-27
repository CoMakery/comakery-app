import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'field' ]

  connect() {
    this._isPasswordField = (this.fieldTarget.type  === 'password')
  }

  copy() {
    this.fieldTarget.focus()
    this.fieldTarget.select()
    this.fieldTarget.setSelectionRange(0, 99999)

    document.execCommand('copy')
  }

  showPasswordField() {
    if (this._isPasswordField) {
      this.fieldTarget.type = 'text'
    }
  }

  hidePasswordField() {
    if (this._isPasswordField) {
      this.fieldTarget.type = 'password'
    }
  }
}

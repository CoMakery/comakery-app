import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'form', 'inputs', 'outputs' ]

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
    this.formTarget.reset()
  }
}

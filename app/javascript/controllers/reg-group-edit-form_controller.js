import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'form', 'show' ]

  showForm() {
    this.formTarget.classList.remove('hidden')

    this.showTargets.forEach((e) => {
      e.classList.add('hidden')
    })
  }

  hideForm() {
    this.formTarget.classList.add('hidden')

    this.showTargets.forEach((e) => {
      e.classList.remove('hidden')
    })
  }
}

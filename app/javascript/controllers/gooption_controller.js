import { Controller } from 'stimulus'
import { Turbo } from '@hotwired/turbo-rails'

export default class extends Controller {
  goOption(e) {
    e.target.disabled = true

    let url = e.target.value

    if (url !== '') {
      Turbo.visit(url)
    } else {
      Turbo.visit(this.data.get('defaultUrl'))
    }
  }
}

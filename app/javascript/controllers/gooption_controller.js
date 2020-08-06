import { Controller } from 'stimulus'
import * as Turbolinks from 'turbolinks'

export default class extends Controller {
  goOption(e) {
    e.target.disabled = true

    let url = e.target.value

    if (url !== '') {
      Turbolinks.visit(url)
    } else {
      Turbolinks.visit(this.data.get('defaultUrl'))
    }
  }
}

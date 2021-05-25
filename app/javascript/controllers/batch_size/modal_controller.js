import { Controller } from 'stimulus'
import jQuery from 'jquery'

export default class extends Controller {
  close() {
    jQuery(this.element).modal('hide')
  }
}

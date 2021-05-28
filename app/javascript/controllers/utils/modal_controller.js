import { Controller } from 'stimulus'

export default class extends Controller {
  close() {
    jQuery(this.element).modal('hide');
  }
}

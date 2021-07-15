import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'settingsDropdown' ];

  resetLazyLoad() {
    $(this.settingsDropdownTarget).next().children().attr('loading', '')
  }
}

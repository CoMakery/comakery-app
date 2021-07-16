import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'mainSide', 'Content', 'DropdownMenu', 'Dropdown' ]

  toggleVerticalNavbar() {
    if( this.mainSideTarget.classList.contains('navbar-collapsed') ) {
      this.mainSideTarget.classList.remove('navbar-collapsed')
      this.ContentTarget.classList.remove('closed-nav-vertical')
    } else {
      this.mainSideTarget.classList.add('navbar-collapsed')
      this.ContentTarget.classList.add('closed-nav-vertical')
    }
  }
}

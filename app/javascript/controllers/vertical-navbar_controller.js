import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'mainSide', 'Content', 'DropdownMenu', 'Dropdown', 'collapsedDropdown', 'collapsedFullDropdown' ]

  toggleVerticalNavbar() {
    if( this.mainSideTarget.classList.contains('navbar-collapsed') ) {
      this.mainSideTarget.classList.remove('navbar-collapsed')
      this.ContentTarget.classList.remove('closed-nav-vertical')
      this.collapsedDropdownTarget.classList.add('hidden')
      this.collapsedFullDropdownTarget.classList.remove('collapsed-full-dropdown')
    } else {
      this.mainSideTarget.classList.add('navbar-collapsed')
      this.ContentTarget.classList.add('closed-nav-vertical')
      this.collapsedDropdownTarget.classList.remove('hidden')
      this.collapsedFullDropdownTarget.classList.add('collapsed-full-dropdown')
    }
  }
}

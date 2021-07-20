import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'mainSide', 'Content', 'DropdownMenu', 'Dropdown', 'collapsedDropdown', 'collapsedFullDropdown', 'mainSideBody', 'mainSideToggler' ]

  initialize() {
    this.myStorage = window.localStorage;

    if(this.myStorage.getItem('opened') === 'yes'){
      this.mainSideBodyTarget.classList.remove('collapse')
      this.mainSideBodyTarget.classList.add('show')
      this.mainSideTogglerTarget.setAttribute('aria-expanded', 'true')
      this.mainSideTogglerTarget.setAttribute('aria-expanded', 'true')
      this.mainSideTarget.classList.remove('navbar-collapsed')
      this.ContentTarget.classList.remove('closed-nav-vertical')
      if( this.hascollapsedDropdownTarget ) {
        this.collapsedDropdownTarget.classList.add('hidden')
        this.collapsedFullDropdownTarget.classList.remove('collapsed-full-dropdown')
      }
    }
  }

  toggleVerticalNavbar() {
    if( this.mainSideTarget.classList.contains('navbar-collapsed') ) {
      this.mainSideTarget.classList.remove('navbar-collapsed')
      this.ContentTarget.classList.remove('closed-nav-vertical')
      if( this.hascollapsedDropdownTarget ) {
        this.collapsedDropdownTarget.classList.add('hidden')
        this.collapsedFullDropdownTarget.classList.remove('collapsed-full-dropdown')
      }
      this.mainSideBodyTarget.classList.remove('collapse')
      this.mainSideBodyTarget.classList.add('show')
      this.mainSideTogglerTarget.setAttribute('aria-expanded', 'true')
      this.myStorage.setItem('opened', 'yes')
    } else {
      this.mainSideTarget.classList.add('navbar-collapsed')
      this.ContentTarget.classList.add('closed-nav-vertical')
      this.mainSideBodyTarget.classList.add('collapse')
      this.mainSideBodyTarget.classList.remove('show')
      this.mainSideTogglerTarget.setAttribute('aria-expanded', 'false')
      if( this.hascollapsedDropdownTarget ) {
        this.collapsedDropdownTarget.classList.remove('hidden')
        this.collapsedFullDropdownTarget.classList.add('collapsed-full-dropdown')
      }
      this.myStorage.setItem('opened', 'no');
    }
  }

  toggleHorizontalNavbar() {
    if( this.mainSideBodyTarget.classList.contains('collapse') ) {
      this.mainSideBodyTarget.classList.remove('collapse')
      this.mainSideBodyTarget.classList.add('show')
      this.mainSideTogglerTarget.setAttribute('aria-expanded', 'true')
      this.mainSideTarget.classList.remove('navbar-collapsed')
      this.ContentTarget.classList.remove('closed-nav-vertical')
      if( this.hascollapsedDropdownTarget ) {
        this.collapsedDropdownTarget.classList.add('hidden')
        this.collapsedFullDropdownTarget.classList.remove('collapsed-full-dropdown')
      }
      localStorage.setItem('opened', 'yes')
    } else {
      this.mainSideBodyTarget.classList.add('collapse')
      this.mainSideBodyTarget.classList.remove('show')
      this.mainSideTogglerTarget.setAttribute('aria-expanded', 'false')
      this.mainSideTarget.classList.add('navbar-collapsed')
      this.ContentTarget.classList.add('closed-nav-vertical')
      if( this.hascollapsedDropdownTarget ) {
        this.collapsedDropdownTarget.classList.remove('hidden')
        this.collapsedFullDropdownTarget.classList.add('collapsed-full-dropdown')
      }
      localStorage.setItem('opened', 'no');
    }
  }
}

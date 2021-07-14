import { Controller } from 'stimulus'

export default class extends Controller {
  initialize() {
    var Handbar = document.querySelector('#main-side-handbar');
    var MainSide = document.querySelector('#main-side')
    var Content = document.querySelector('.content')
    var DropdownMenu = document.querySelector('.dropdown-menu')
    var Dropdown = document.querySelector('.dropdown')
    var DropdownBtn = document.querySelector('.dropdown-btn')

    Handbar.addEventListener('click', (event) => {
      event.preventDefault();

      if( MainSide.classList.contains('navbar-collapsed') ) {
        MainSide.classList.remove('navbar-collapsed')
        Content.classList.remove('navbar-ms-0')
        Content.classList.remove('navbar-ms-1')
        Content.classList.remove('navbar-ms-2')
      } else {
        MainSide.classList.add('navbar-collapsed')
        Content.classList.add('navbar-ms-0')
        Content.classList.remove('navbar-ms-1')
        Content.classList.remove('navbar-ms-2')
        DropdownMenu.classList.remove('show')
        Dropdown.classList.remove('active')
      }
    });

    DropdownBtn.addEventListener('click', (event) => {
      event.preventDefault();
      if( MainSide.classList.contains('navbar-collapsed') ) {
        MainSide.classList.remove('navbar-collapsed')
        Content.classList.remove('navbar-ms-0')
        Content.classList.remove('navbar-ms-1')
        Content.classList.remove('navbar-ms-2')
        DropdownMenu.classList.add('show')
        Dropdown.classList.add('active')
      } else if( !DropdownMenu.classList.contains('show') ) {
        DropdownMenu.classList.add('show')
        Dropdown.classList.add('active')
      } else {
        DropdownMenu.classList.remove('show')
        Dropdown.classList.remove('active')
      }
    });
  }
}

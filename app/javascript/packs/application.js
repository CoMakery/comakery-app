/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %>
// to the appropriate layout file

// Support IE11
import 'react-app-polyfill/ie11'
import 'react-app-polyfill/stable'

// Support ES6 syntax
import 'babel-polyfill'

import '../src/application.js'

import '../src/application.css'

import 'slick-carousel/slick/slick.css'

import 'slick-carousel/slick/slick-theme.css'

import Rails from 'rails-ujs'
Rails.start()

// Support component names relative to this directory:
let componentRequireContext = require.context('components', true)
let ReactRailsUJS = require('react_ujs')
ReactRailsUJS.useContext(componentRequireContext)

// By default, this pack is loaded for server-side rendering.

// Support ES6 syntax
import 'babel-polyfill'

import '../src/application.css'

import 'slick-carousel/slick/slick.css'

import 'slick-carousel/slick/slick-theme.css'

// It must expose react_ujs as `ReactRailsUJS` and prepare a require context.
let componentRequireContext = require.context('components', true)
let ReactRailsUJS = require('react_ujs')
ReactRailsUJS.useContext(componentRequireContext)

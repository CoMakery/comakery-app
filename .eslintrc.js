const OFF = 0
const WARN = 1
const ERR = 2

const unusedVars = [
  'd', // debug
]

const config = {
  env: {
    browser: true,
    jquery : true,
    es6    : true,
    jest   : true
  },
  extends: 'comakery',
  globals: {
    'App'        : true,
    'ActionCable': true,
    'Utils'      : true,
    'window'     : false,
  },
  rules: {
    'complexity'                 : [ERR, { 'max': 22 }],
    'jsx-quotes'                 : [ERR, 'prefer-double'],
    'key-spacing'                : [ERR, {'align': 'colon'}],
    'no-debugger'                : OFF,
    'no-unused-vars'             : [WARN, { 'argsIgnorePattern': '^_', 'varsIgnorePattern': '^(' + unusedVars.join('|') + ')$' }],
    'no-warning-comments'        : OFF,
    'promise/always-return'      : OFF,
    'promise/catch-or-return'    : OFF,
    'react/prop-types'           : OFF,
    'space-before-function-paren': [ERR, 'never'],
  },
}

module.exports = config

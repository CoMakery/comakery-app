const { environment } = require('@rails/webpacker')

// https://github.com/reactjs/react-rails/issues/985
// ReferenceError: window is not defined
environment.config.set(
  'output.globalObject',
  "(typeof self !== 'undefined' ? self : this)"
)

module.exports = environment

const environment = require('./environment')

// fix: in production, cannot send qtum coins (Expected Point, got s)
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')
environment.plugins.delete('UglifyJs')
environment.plugins.append('UglifyJs', new UglifyJsPlugin({
  parallel     : true,
  cache        : true,
  sourceMap    : true,
  uglifyOptions: {
    parse: {
      // Let uglify-js parse ecma 8 code but always output
      // ES5 compliant code for older browsers
      ecma: 8
    },
    compress: {
      ecma       : 5,
      warnings   : false,
      comparisons: false
    },
    mangle: {
      safari10: true,
      reserved: [
        'Point',
        'ECPair'
      ]
    },
    output: {
      ecma      : 5,
      comments  : false,
      ascii_only: true
    }
  }
}))

module.exports = environment.toWebpackConfig()

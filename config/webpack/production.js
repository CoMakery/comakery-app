process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')

environment.loaders.delete('nodeModules')

const config = environment.toWebpackConfig()

config.optimization = {
  minimizer: [
    new UglifyJsPlugin({
      uglifyOptions: {
        mangle: {
            reserved: [
                'Buffer',
                'BigInteger',
                'Point',
                'ECPubKey',
                'ECKey',
                'sha512_asm',
                'asm',
                'ECPair',
                'HDNode'
            ]
        }
      }
    })
  ]
}

module.exports = config

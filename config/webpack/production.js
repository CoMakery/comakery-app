process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

environment.loaders.delete('nodeModules')

const config = environment.toWebpackConfig()

module.exports = config

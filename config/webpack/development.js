process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')

environment.loaders.delete('nodeModules')

const config = environment.toWebpackConfig()

module.exports = config
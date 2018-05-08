class EthereumUtilSchmoozer < Schmooze::Base
  dependencies eth_util: './lib/assets/javascripts/eth_util'

  method :verify_signature, 'eth_util.verify_signature'
end

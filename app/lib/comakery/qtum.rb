require 'open-uri'
require 'json'

class Comakery::Qtum
  attr_reader :host

  def initialize(network)
    @host = case network
            when 'qtum_testnet'
              'testnet.qtum.info'
            when 'qtum_mainnet'
              'qtum.info'
    end
  end

  def contract(address)
    JSON.parse((open "https://#{host}/api/contract/#{address}").read)
  end

  def fetch_symbol_and_decimals(address)
    c = contract(address)
    [
      c['qrc20']['symbol'],
      c['qrc20']['decimals'].to_i
    ]
  rescue
    [
      nil,
      nil
    ]
  end
end

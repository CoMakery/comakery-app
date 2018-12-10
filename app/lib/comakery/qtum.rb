require 'open-uri'
require 'json'

class Comakery::Qtum
  def initialize(network)
    @host = case network
    when 'qtum_testnet'
      'testnet.qtum.info'
    when 'qtum_mainnet'
      'qtum.info'
    end
  end

  def fetch_symbol_and_decimals(address)
    contract = JSON.parse((open "https://#{@host}/api/contract/#{address}").read)
    [
      contract["qrc20"]["symbol"],
      contract["qrc20"]["decimals"].to_i
    ]
  rescue
    [
      nil,
      nil
    ]
  end
end

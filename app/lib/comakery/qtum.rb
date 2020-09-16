require 'open-uri'
require 'json'

class Comakery::Qtum
  attr_reader :host

  def initialize(host)
    @host = host
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
  rescue StandardError
    [
      nil,
      nil
    ]
  end
end

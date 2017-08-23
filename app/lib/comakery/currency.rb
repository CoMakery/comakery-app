module Comakery
  module Currency
    USD = 'USD'.freeze
    BTC = 'BTC'.freeze
    ETH = 'ETH'.freeze

    DENOMINATIONS = {
      USD => '$',
      BTC => '฿',
      ETH => 'Ξ'
    }.freeze

    PRECISION = {
      USD => 2,
      BTC => 8,
      ETH => 18
    }.freeze

    PER_SHARE_PRECISION = {
      USD => 8,
      BTC => 8,
      ETH => 8
    }.freeze

    ROUNDED_BALANCE_PRECISION = {
      USD => 2,
      BTC => 8,
      ETH => 8
    }.freeze
    DEFAULT_MIN_PAYMENT = {
      USD => 1,
      BTC => 0.001,
      ETH => 0.1
    }.freeze
  end
end

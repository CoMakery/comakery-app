module Comakery
  module Currency
    USD = "USD"
    BTC = "BTC"
    ETH = "ETH"

    DENOMINATIONS = {
        USD => "$",
        BTC => "฿",
        ETH => "Ξ"
    }

    PRECISION = {
        USD => 2,
        BTC => 8,
        ETH => 18
    }

    PER_SHARE_PRECISION = {
        USD => 8,
        BTC => 8,
        ETH => 8
    }

    ROUNDED_BALANCE_PRECISION = {
        USD => 2,
        BTC => 8,
        ETH => 8
    }
    DEFAULT_MIN_PAYMENT = {
        USD => 10,
        BTC => 0.001,
        ETH => 0.1
    }
  end
end
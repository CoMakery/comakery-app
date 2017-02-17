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
  end
end
module Comakery::Currency
  DENOMINATIONS = {
      "USD" => "$",
      "BTC" => "฿",
      "ETH" => "Ξ"
  }

  PRECISION = {
      'USD' => 2,
      'BTC' => 8,
      'ETH' => 18
  }

  PER_SHARE_PRECISION = {
      'USD' => 4,
      'BTC' => 8,
      'ETH' => 18
  }
end
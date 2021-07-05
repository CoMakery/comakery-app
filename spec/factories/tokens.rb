FactoryBot.define do
  factory :token do
    sequence(:name) { |n| "Token #{n}" }
    blockchain_network { :bitcoin_mainnet }
    _blockchain { :bitcoin }
    decimal_places { 0 }
    denomination { :BTC }
    coin_type { :btc }
    symbol { :BTC }

    trait :eth do
      symbol { nil }
      _token_type { :eth }
    end

    trait :ropsten do
      _blockchain { :ethereum_ropsten }
    end
  end
end

FactoryBot.define do
  factory :token do
    sequence(:name) { |n| "Token #{n}" }
    coin_type { :btc }
    blockchain_network { :bitcoin_mainnet }
    symbol { :BTC }
    _blockchain { :bitcoin }
    decimal_places { 0 }

    trait :security_token do
      logo_image { Rack::Test::UploadedFile.new('spec/fixtures/dummy_image.png', 'image/png') }
      contract_address { '0x1d1592c28fff3d3e71b1d29e31147846026a0a37' }
      _token_type { :comakery_security_token }
      _blockchain { :ethereum_ropsten }
      symbol { :XYZ2 }
      decimal_places { 0 }
    end
  end
end

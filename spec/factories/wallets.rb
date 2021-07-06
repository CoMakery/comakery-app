FactoryBot.define do
  factory :wallet do
    account
    sequence(:name) { |n| "Wallet #{n}" }
    _blockchain { :bitcoin }
    address { '3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt' }
    account

    trait :ropsten do
      _blockchain { :ethereum_ropsten }
      address { '0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB' }
    end
  end
end

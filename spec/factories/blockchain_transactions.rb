FactoryBot.define do
  factory :blockchain_transaction do
    token
    network { :ethereum }
    destination { '0xbbc7e3ee37977ca508f63230471d1001d22bfdd5' }
    tx_hash { '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d' }

    trait :ropsten do
      network { :ethereum_ropsten }
      token { association :token, :eth, :ropsten }
      source { '0xbbc7e3ee37977ca508f63230471d1001d22bfdd5' }
      current_block { 0 }
    end
  end
end

FactoryBot.define do
  factory :ore_id_account do
    account
    sequence(:account_name) { |n| "Ore Id Account #{n}" }
  end
end

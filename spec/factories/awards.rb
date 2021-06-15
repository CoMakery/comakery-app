FactoryBot.define do
  factory :award do
    account
    transfer_type
    award_type
    sequence(:name) { |n| "Award #{n}" }
    amount { 10 }
    image { dummy_image }
  end
end

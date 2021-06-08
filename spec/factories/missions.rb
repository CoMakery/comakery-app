FactoryBot.define do
  factory :mission do
    sequence(:name) { |n| "Mission #{n}" }
    subtitle { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
  end
end

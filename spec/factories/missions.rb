FactoryBot.define do
  factory :mission do
    sequence(:name) { |n| "Mission #{n}" }
    subtitle { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    image { dummy_image }
    logo { dummy_image }
  end
end

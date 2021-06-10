FactoryBot.define do
  factory :team do
    provider { Faker::Lorem.word }

    trait(:slack) { provider { :slack } }
    trait(:discord) { provider { :discord } }
  end
end

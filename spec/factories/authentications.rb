FactoryBot.define do
  factory :authentication do
    account
    provider { Faker::Lorem.word }
    uid { Faker::Internet.uuid }

    trait(:slack) { provider { :slack } }
    trait(:discord) { provider { :discord } }
  end
end

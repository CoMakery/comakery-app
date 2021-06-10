FactoryBot.define do
  factory :project do
    account
    mission
    token
    long_id { Faker::Internet.uuid }
    title { Faker::Lorem.words(number: 2).join(' ') }
    description { Faker::Lorem.sentence(word_count: 5) }
  end
end

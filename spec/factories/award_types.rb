FactoryBot.define do
  factory :award_type do
    project
    sequence(:name) { |n| "Award Type #{n}" }
    goal { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.sentence }

    trait :ropsten do
      association :project, factory: %i[project ropsten]
    end
  end
end

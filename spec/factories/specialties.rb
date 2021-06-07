FactoryBot.define do
  factory :specialty do
    sequence(:name) { |n| "Speciality #{n}" }
  end
end

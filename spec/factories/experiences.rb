FactoryBot.define do
  factory :experience do
    account
    specialty
    level { rand(10) }
  end
end

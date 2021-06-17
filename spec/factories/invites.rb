FactoryBot.define do
  factory :invite do
    email { Faker::Internet.email }
    token { SecureRandom.hex(6) }
    role { 'interested' }
    accepted { false }
  end
end

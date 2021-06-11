FactoryBot.define do
  factory :invite do
    token { SecureRandom.hex(6) }
    role { :interested }
    accepted { false }
  end
end

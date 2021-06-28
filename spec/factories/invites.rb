FactoryBot.define do
  factory :invite do
    email { Faker::Internet.email }
    accepted { false }
    association :invitable, factory: :project_role, account: nil

    trait :for_admin do
      association :invitable, factory: :project_role, account: nil, role: :admin
    end

    trait :accepted do
      accepted { true }
      account
    end

    trait :accepted_with_forced_email do
      accepted
      force_email { true }
      email { account.email }
    end
  end
end

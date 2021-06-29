FactoryBot.define do
  factory :project_role do
    project
    account

    trait(:admin) { role { :admin } }
    trait(:interested) { role { :interested } }
    trait(:observer) { role { :observer } }
  end
end

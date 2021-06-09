FactoryBot.define do
  factory :transfer_type do
    project
    sequence(:name) { |n| "Transfer Type #{n}" }
    default { false }
  end
end

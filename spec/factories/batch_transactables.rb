FactoryBot.define do
  factory :batch_transactable do
    transaction_batch
    blockchain_transactable
  end
end

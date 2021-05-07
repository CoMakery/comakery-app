class BatchTransactable < ApplicationRecord
  belongs_to :transaction_batch
  belongs_to :blockchain_transactable, polymorphic: true

  scope :prioritization_support, -> { where(blockchain_transactable_type: %w[Award AccountTokenRecord]) }
end

class BatchTransactable < ApplicationRecord
  belongs_to :transaction_batch
  belongs_to :blockchain_transactable, polymorphic: true
end

class BlockchainTransactionUpdate < ApplicationRecord
  belongs_to :blockchain_transaction

  enum status: { created: 0, pending: 1, cancelled: 2, succeed: 3, failed: 4 }
end

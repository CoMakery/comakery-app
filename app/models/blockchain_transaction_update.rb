class BlockchainTransactionUpdate < ApplicationRecord
  belongs_to :blockchain_transaction

  enum status: %i[created pending cancelled succeed failed]
end

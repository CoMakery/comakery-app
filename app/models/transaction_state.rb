class TransactionState < ApplicationRecord
  belongs_to :transaction

  enum status: %i[created pending cancelled succeed failed]
end

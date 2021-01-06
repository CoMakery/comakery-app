class TokenOptIn < ApplicationRecord
  include BlockchainTransactable

  belongs_to :wallet
  belongs_to :token

  enum status: { require_opt_in: 0, pending: 1, opted_in: 2 }

  validates :wallet_id, uniqueness: { scope: :token_id }
end

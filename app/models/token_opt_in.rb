class TokenOptIn < ApplicationRecord
  include BlockchainTransactable

  belongs_to :wallet
  belongs_to :token

  enum status: { pending: 0, synced: 1 }

  validates :wallet_id, uniqueness: { scope: :token_id }
end

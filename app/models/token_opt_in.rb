class TokenOptIn < ApplicationRecord
  belongs_to :wallet
  belongs_to :token

  enum status: { pending: 0, synced: 1 }
end

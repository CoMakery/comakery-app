class Wallet < ApplicationRecord
  include BelongsToBlockchain

  belongs_to :account
  has_many :balances, dependent: :destroy

  validates :address, :state, :source, presence: true
  validates :address, blockchain_address: true
  validates :_blockchain, uniqueness: { scope: :account_id }

  enum state: { ok: 0, pending: 1, unclaimed: 2 }
  enum source: { user_provided: 0, ore_id: 1 }
end

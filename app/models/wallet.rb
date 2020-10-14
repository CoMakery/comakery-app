class Wallet < ApplicationRecord
  include BelongsToBlockchain
  include OreIdFeatures

  belongs_to :account
  has_many :balances, dependent: :destroy

  validates :state, :source, presence: true
  validates :address, presence: true, unless: :ore_id_and_pending?
  validates :address, blockchain_address: true
  validates :_blockchain, uniqueness: { scope: :account_id, message: 'has already wallet added' }

  attr_readonly :_blockchain

  enum state: { ok: 0, unclaimed: 1, pending: 2 }
  enum source: { user_provided: 0, ore_id: 1 }

  def available_blockchains
    Wallet._blockchains.keys - account.wallets.pluck(:_blockchain)
  end

  private

    def ore_id_and_pending?
      pending? && ore_id?
    end
end

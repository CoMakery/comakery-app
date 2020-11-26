class Wallet < ApplicationRecord
  include BelongsToBlockchain
  include BelongsToOreId

  belongs_to :account
  has_many :balances, dependent: :destroy
  has_many :token_opt_ins, dependent: :destroy

  validates :source, presence: true
  validates :address, presence: true, unless: :pending?
  validates :address, blockchain_address: true
  validates :_blockchain, uniqueness: { scope: :account_id, message: 'has already wallet added' }

  attr_readonly :_blockchain

  enum source: { user_provided: 0, ore_id: 1 }

  def available_blockchains
    available_blockchains = Blockchain.available
    available_blockchains.reject!(&:supported_by_ore_id?)
    available_blockchains.map(&:key) - account.wallets.pluck(:_blockchain)
  end

  def pending?
    ore_id? && ore_id_account&.pending?
  end
end

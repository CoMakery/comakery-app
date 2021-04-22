class Wallet < ApplicationRecord
  include BelongsToBlockchain
  include BelongsToOreId

  belongs_to :account, optional: true
  belongs_to :project, optional: true
  has_many :balances, dependent: :destroy
  has_many :token_opt_ins, dependent: :destroy
  has_many :wallet_provisions, dependent: :destroy
  has_many :awards, foreign_key: :recipient_wallet_id, inverse_of: :recipient_wallet, dependent: :nullify
  has_many :account_token_records, dependent: :destroy

  scope :with_whitelabel_account, lambda {
    left_outer_joins(account: :managed_mission).where(missions: { whitelabel: true })
  }

  validates :source, presence: true
  validates :address, presence: true, unless: :empty_address_allowed?
  validates :address, blockchain_address: true
  validates :address, uniqueness: { scope: %i[account_id _blockchain], allow_nil: true, message: 'has already been taken for the blockchain' }
  validates :_blockchain, uniqueness: { scope: %i[account_id primary_wallet], message: 'has primary wallet already' }, if: :primary_wallet?
  validates :name, presence: true
  validates :project_id, presence: true, if: :hot_wallet?
  validates :account_id, presence: true, unless: :hot_wallet?
  validate :blockchain_supported_by_ore_id, if: :ore_id?

  attr_readonly :_blockchain

  before_create :set_primary_flag
  after_commit :mark_first_wallet_as_primary, on: [:destroy], if: :primary_wallet?

  after_create_commit { broadcast_append_later_to 'wallets' if account_whitelabel? }
  after_update_commit { broadcast_replace_to 'wallets' if account_whitelabel? }
  after_destroy_commit { broadcast_remove_to 'wallets' if account_whitelabel? }

  enum source: { user_provided: 0, ore_id: 1, hot_wallet: 2 }

  def available_blockchains
    available_blockchains = Blockchain.available

    # TODO: Add Blockchain flag to indicate availability, regardless ore_id support
    available_blockchains.reject! { |b| b.is_a? Blockchain::Algorand }
    available_blockchains.map(&:key)
  end

  def coin_balance
    balance = balances.find_or_create_by(token: coin_of_the_blockchain)
    SyncBalanceJob.set(queue: :critical).perform_later(balance)
    balance
  end

  def set_primary_flag
    self.primary_wallet = !Wallet.exists?(account_id: account_id,
                                          _blockchain: _blockchain,
                                          primary_wallet: true)
  end

  def mark_first_wallet_as_primary
    first_wallet_in_network = Wallet
                              .where(account_id: account_id, _blockchain: _blockchain)
                              .order(id: :asc)
                              .first

    first_wallet_in_network&.update_column(:primary_wallet, true) # rubocop:disable Rails/SkipsModelValidations
  end

  # TODO: Move opt-in logic into `Blockchain` and `TokenType`
  def sync_opt_ins
    if blockchain.is_a?(Blockchain::Algorand)
      sync_assets_opt_ins
      sync_apps_opt_ins
    end
  end

  def sync_assets_opt_ins
    assets = Comakery::Algorand.new(blockchain).account_assets(address)
    asset_ids = assets.map { |a| a.fetch('asset-id') }
    asset_tokens = Token._token_type_asa.where(contract_address: asset_ids)
    asset_tokens.each do |token|
      opt_in = TokenOptIn.find_or_create_by(wallet: self, token: token)
      opt_in.opted_in!
    end
  end

  def sync_apps_opt_ins
    apps = Comakery::Algorand.new(blockchain).account_apps(address)
    app_ids = apps.map { |a| a.fetch('id') }
    app_tokens = Token._token_type_algorand_security_token.where(contract_address: app_ids)
    app_tokens.each do |token|
      opt_in = TokenOptIn.find_or_create_by(wallet: self, token: token)
      opt_in.opted_in!
    end
  end

  def state
    if ore_id?
      ore_id_account&.state
    else
      'ok'
    end
  end

  private

    def blockchain_supported_by_ore_id
      errors.add(:_blockchain, 'is not supported with ore_id source') unless blockchain.supported_by_ore_id?
    end

    def empty_address_allowed?
      ore_id? && (wallet_provisions.empty? || wallet_provisions.any?(&:pending?))
    end

    def account_whitelabel?
      account&.managed_mission&.whitelabel?
    end
end

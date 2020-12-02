class OreIdAccount < ApplicationRecord
  class OreIdAccount::ProvisioningError < StandardError; end
  include Synchronisable

  belongs_to :account
  has_many :wallets, dependent: :destroy

  before_create :set_temp_password
  after_create :schedule_sync, unless: :pending_manual?
  after_update :schedule_wallet_sync, if: :saved_change_to_account_name?
  after_update :schedule_balance_sync, if: :saved_change_to_account_name? && :pending?
  after_update :schedule_create_opt_in_tx, if: :saved_change_to_provisioning_stage? && :initial_balance_confirmed?
  after_update :schedule_opt_in_tx_sync, if: :saved_change_to_provisioning_stage? && :opt_in_created?

  validates :account_name, uniqueness: { allow_nil: true, allow_blank: false }

  # NOTE: There are two possible flows for ORE ID creation
  #
  # 1) Manual Flow – account created by user on ORE ID service website and passed to CoMakery with a callback.
  # -- account created via auth:ore_id#new action --> (state: manual_pending)
  # -- account name received via auth:ore_id#receive action --> (state: ok)
  #
  # 2) Auto Provisioning Flow – account created by CoMakery using ORE ID API.
  # -- account created via ORE ID API --> (state: pending, provisioning_stage: not_provisioned)
  # -- account balance confirmed on chain --> (state: pending, provisioning_stage: initial_balance_confirmed)
  # -- opt in tx created via ORE ID API --> (state: pending, provisioning_stage: opt_in_created)
  # -- opt in tx confirmed on chain --> (state: pending, provisioning_stage: provisioned)
  # -- CoMakery password reset api endpoint called --> (state: unclaimed, provisioning_stage: provisioned)
  # -- passwordUpdatedAt on ORE ID API response has been changed --> (state: ok, provisioning_stage: provisioned)

  enum state: {
    pending: 0,
    pending_manual: 1,
    unclaimed: 2,
    ok: 3,
    unlinking: 4
  }

  enum provisioning_stage: {
    not_provisioned: 0,
    initial_balance_confirmed: 1,
    opt_in_created: 2,
    provisioned: 3
  }

  def service
    @service ||= OreIdService.new(self)
  end

  def sync_account
    service.create_remote
  end

  def sync_wallets
    service.permissions.each do |permission|
      w = Wallet.find_or_initialize_by(
        account: account,
        source: :ore_id,
        _blockchain: permission[:_blockchain]
      )

      w.ore_id_account = self
      w.address = permission[:address]
      w.save!
    end

    ok!
  end

  def provisioning_wallet
    wallets.last
  end

  def provisioning_tokens
    Token._token_type_asa
  end

  def sync_balance
    if provisioning_wallet&.coin_balance&.value&.positive?
      initial_balance_confirmed!
    else
      raise OreIdAccount::ProvisioningError, 'Balance is not ready'
    end
  end

  def create_opt_in_tx
    provisioning_tokens.each do |token|
      opt_in = TokenOptIn.find_or_create_by(wallet: provisioning_wallet, token: token)
      opt_in.pending!

      service.create_tx(BlockchainTransactionOptIn.create!(blockchain_transactable: opt_in))
    end

    opt_in_created!
  end

  def sync_opt_in_tx
    if provisioning_wallet.token_opt_ins.all?(&:opted_in?)
      provisioned!
    else
      raise OreIdAccount::ProvisioningError, 'OptIn tx is not ready'
    end
  end

  def unlink
    unlinking!
    destroy!
  end

  def sync_password_update
    if service.password_updated?
      ok!
    else
      raise OreIdAccount::ProvisioningError, 'Password is not updated'
    end
  end

  def schedule_sync
    OreIdSyncJob.perform_later(id)
  end

  def schedule_wallet_sync
    OreIdWalletsSyncJob.perform_later(id)
  end

  def schedule_balance_sync
    OreIdBalanceSyncJob.perform_later(id)
  end

  def schedule_create_opt_in_tx
    OreIdOptInTxCreateJob.perform_later(id)
  end

  def schedule_opt_in_tx_sync
    OreIdOptInTxSyncJob.perform_later(id)
  end

  def schedule_password_update_sync
    OreIdPasswordUpdateSyncJob.set(wait: 60).perform_later(id)
  end

  private

    def set_temp_password
      self.temp_password ||= SecureRandom.hex(32) + '!'
    end
end

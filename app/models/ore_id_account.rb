class OreIdAccount < ApplicationRecord
  include Synchronisable

  belongs_to :account
  has_many :wallets, dependent: :destroy

  before_create :set_temp_password
  after_create :schedule_sync, unless: :pending_manual?
  after_update :schedule_wallet_sync, if: :saved_change_to_account_name?

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
    ok: 3
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

  def sync_balance
    if wallets.last&.coin_balance&.value&.positive?
      initial_balance_confirmed!
    else
      raise StandardError, 'Account balance is 0'
    end
  end

  def create_opt_in_tx
    # TODO: Integrate tx creation
    # service.create_tx(tx)
    service

    opt_in_created!
  end

  def sync_opt_in_tx
    # TODO: Integrate tx confirmation
    # Algorand tx status check
    service

    provisioned!
  end

  def sync_password_update
    ok! if service.password_updated?
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

  def schedule_opt_in_tx_sync
    OreIdOptInTxSyncJob.perform_later(id)
  end

  def schedule_create_opt_in_tx
    OreIdOptInTxCreateJob.perform_later(id)
  end

  def schedule_password_update_sync
    OreIdPasswordUpdateSyncJob.perform_later(id)
  end

  private

    def set_temp_password
      self.temp_password ||= SecureRandom.hex(32) + '!'
    end
end

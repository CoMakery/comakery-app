class OreIdAccount < ApplicationRecord
  class OreIdAccount::ProvisioningError < StandardError; end
  include Synchronisable
  include AASM

  belongs_to :account
  has_many :wallets, dependent: :destroy
  has_many :wallet_provisions, through: :wallets

  before_create :set_temp_password
  after_create :schedule_sync, unless: :pending_manual?

  validates :account_name, uniqueness: { allow_nil: true, allow_blank: false }

  # NOTE: There are two possible flows for ORE ID creation
  #
  # 1) Manual Flow – account created by user on ORE ID service website and passed to CoMakery with a callback.
  # -- account created via auth:ore_id#new action --> (state: pending_manual)
  # -- account name received via auth:ore_id#receive action --> (state: ok)
  #
  # 2) Auto Provisioning Flow – see description in WalletProvision

  enum state: {
    pending: 0,
    pending_manual: 1,
    unclaimed: 2,
    ok: 3,
    unlinking: 4
  }

  aasm column: :state, enum: true, timestamps: true do
    state :pending, initial: true
    state :pending_manual
    state :unclaimed
    state :ok
    state :unlinking

    event :create_remote do
      before do
        create_account
        pull_wallets
        push_wallets
        sync_opt_ins
      end

      transitions from: :pending, to: :unclaimed
    end

    event :sync_remote do
      before do
        pull_wallets
        push_wallets unless ok?
        sync_opt_ins
      end

      transitions from: :unclaimed, to: :unclaimed
      transitions from: %i[pending_manual ok], to: :ok
    end

    event :claim do
      before do
        sync_password_update if no_pending_provisions?
      end

      transitions from: :unclaimed, to: :ok, if: :no_pending_provisions?
    end

    event :unlink do
      after do
        destroy!
      end

      transitions to: :unlinking
    end
  end

  def no_pending_provisions?
    wallet_provisions.empty? || wallet_provisions.all?(&:provisioned?)
  end

  def service
    @service ||= OreIdService.new(self)
  end

  def create_account
    service.create_remote
  end

  def pull_wallets
    service.permissions.each do |permission|
      next if account.wallets.find_by(
        source: :ore_id,
        _blockchain: permission[:_blockchain],
        address: permission[:address]
      )

      w = account.wallets.find_or_initialize_by(
        source: :ore_id,
        _blockchain: permission[:_blockchain],
        address: nil
      )

      w.address = permission[:address]
      w.ore_id_account = self
      w.name ||= w.blockchain.name
      w.save!
    end
  end

  def push_wallets
    account.wallets.where(source: :ore_id, address: nil).find_each do |wallet|
      service.create_wallet(wallet.blockchain)
    end
  end

  def sync_opt_ins
    wallets.each(&:sync_opt_ins)
  end

  def sync_password_update
    raise OreIdAccount::ProvisioningError, 'Password is not updated' unless service.password_updated?
  end

  def schedule_sync
    OreIdSyncJob.perform_later(id)
  end

  def schedule_wallet_sync
    OreIdWalletsSyncJob.perform_later(id)
  end

  def schedule_password_update_sync
    OreIdPasswordUpdateSyncJob.set(wait: 60).perform_later(id)
  end

  private

    def set_temp_password
      self.temp_password ||= SecureRandom.hex(32) + '!'
    end
end

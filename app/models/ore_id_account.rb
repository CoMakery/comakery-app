class OreIdAccount < ApplicationRecord
  class OreIdAccount::ProvisioningError < StandardError; end
  include Synchronisable

  belongs_to :account
  has_many :wallets, dependent: :destroy
  has_many :wallet_provisions, through: :wallets

  before_create :set_temp_password
  after_create :schedule_sync, unless: :pending_manual?
  after_update :schedule_wallet_sync, if: :saved_change_to_account_name?
  after_update :schedule_opt_in_sync, if: :saved_change_to_state? && :ok?

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
      w.name ||= w.blockchain.name
      w.save!
    end

    ok! if wallet_provisions.empty?
  end

  def sync_opt_ins
    wallets.each do |wallet|
      client = Comakery::Algorand.new(wallet.blockchain)
      sync_assets_opt_ins(client, wallet)
      sync_apps_opt_ins(client, wallet)
    end
  end

  def sync_assets_opt_ins(client, wallet)
    assets = client.account_assets(wallet.address)
    asset_ids = assets.map { |a| a.fetch('asset-id') }
    asset_tokens = Token._token_type_asa.where(contract_address: asset_ids)
    asset_tokens.each do |token|
      opt_in = TokenOptIn.find_or_create_by(wallet: wallet, token: token)
      opt_in.opted_in!
    end
  end

  def sync_apps_opt_ins(client, wallet)
    apps = client.account_apps(wallet.address)
    app_ids = apps.map { |a| a.fetch('id') }
    app_tokens = Token._token_type_algorand_security_token.where(contract_address: app_ids)
    app_tokens.each do |token|
      opt_in = TokenOptIn.find_or_create_by(wallet: wallet, token: token)
      opt_in.opted_in!
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

  def schedule_password_update_sync
    OreIdPasswordUpdateSyncJob.set(wait: 60).perform_later(id)
  end

  def schedule_opt_in_sync
    OreIdOptInSyncJob.perform_later(id)
  end

  private

    def set_temp_password
      self.temp_password ||= SecureRandom.hex(32) + '!'
    end
end

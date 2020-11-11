class OreIdAccount < ApplicationRecord
  include Synchronisable

  belongs_to :account
  has_many :wallets, dependent: :destroy

  after_create :schedule_sync, unless: :pending_manual?
  after_update :schedule_wallet_sync

  enum state: { pending: 0, pending_manual: 1, unclaimed: 2, ok: 3 }

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
      w.state = :ok
      w.address = permission[:address]
      w.save!
    end
  end

  private

    def schedule_sync
      OreIdSyncJob.perform_later(id)
    end

    def schedule_wallet_sync
      OreIdWalletsSyncJob.perform_later(id)
    end
end

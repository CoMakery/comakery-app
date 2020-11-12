class OreIdAccount < ApplicationRecord
  include Synchronisable

  belongs_to :account
  has_many :wallets, dependent: :destroy
  after_create :schedule_sync

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
      OreIdWalletsSyncJob.perform_later(id)
    end
end

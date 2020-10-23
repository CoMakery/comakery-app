class OreId < ApplicationRecord
  belongs_to :account
  has_many :wallets, dependent: :destroy
  after_create :schedule_sync_wallets

  def service
    @service ||= OreIdService.new(self)
  ensure
    update(account_name: @service.account_name) if @service&.account_name && account_name.nil?
  end

  def sync_wallets
    service.permissions.each do |permission|
      w = Wallet.find_or_initialize_by(
        account: account,
        source: :ore_id,
        _blockchain: permission[:_blockchain]
      )

      w.ore_id = self
      w.state = :ok
      w.address = permission[:address]
      w.save!
    end
  end

  private

    def schedule_sync_wallets
      OreIdSyncJob.perform_later(self)
    end
end

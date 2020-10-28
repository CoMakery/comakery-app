class OreIdWalletsSyncJob < ApplicationJob
  queue_as :default

  def perform(id)
    ore_id = OreIdAccount.find(id)
    ore_id.sync_wallets
  rescue OreIdService::RemoteInvalidError
    self.class.set(wait: 10.seconds).perform_later(id)
  end
end

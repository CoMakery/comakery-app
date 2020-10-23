class OreIdSyncJob < ApplicationJob
  queue_as :default

  def perform(ore_id)
    ore_id.sync_wallets
  end
end

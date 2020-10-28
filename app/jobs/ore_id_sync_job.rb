class OreIdSyncJob < ApplicationJob
  queue_as :default

  def perform(id)
    ore_id = OreIdAccount.find(id)
    ore_id.service.create_remote
  end
end

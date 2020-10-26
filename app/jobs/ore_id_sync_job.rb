class OreIdSyncJob < ApplicationJob
  queue_as :default

  def perform(id)
    ore_id = OreId.find(id)
    ore_id.service.create_remote
  end
end

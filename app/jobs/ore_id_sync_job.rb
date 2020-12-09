class OreIdSyncJob < ApplicationJob
  queue_as :default

  def perform(id)
    ore_id = OreIdAccount.find(id)

    unless ore_id.sync_allowed?
      reschedule(ore_id)
      return
    end

    sync = ore_id.create_synchronisation

    begin
      ore_id.sync_account
    rescue StandardError => e
      sync.failed!
      reschedule(ore_id)
      raise e
    else
      sync.ok!
    end
  end

  def reschedule(ore_id)
    self.class.set(wait: ore_id.next_sync_allowed_after - Time.current).perform_later(ore_id.id)
  end
end

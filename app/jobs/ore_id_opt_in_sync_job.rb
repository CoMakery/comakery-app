class OreIdOptInSyncJob < ApplicationJob
  queue_as :default

  def perform(id)
    ore_id = OreIdAccount.find(id)

    unless ore_id.sync_allowed?
      reschedule(ore_id)
      return
    end

    sync = ore_id.create_synchronisation

    begin
      ore_id.sync_opt_ins
    rescue StandardError => e
      sync.failed!
      reschedule(ore_id)
      raise e
    else
      sync.ok!
    end
  end

  def reschedule(ore_id)
    self.class.set(wait: ore_id.next_sync_allowed_after(scale: :linear) - Time.current).perform_later(ore_id.id)
  end
end

class OreIdPasswordUpdateSyncJob < ApplicationJob
  queue_as :default

  def perform(id)
    ore_id = OreIdAccount.find(id)

    unless ore_id.sync_allowed?
      reschedule(ore_id)
      return
    end

    sync = ore_id.create_synchronisation

    begin
      ore_id.claim!
    rescue OreIdAccount::ProvisioningError
      sync.failed!
      reschedule(ore_id)
    rescue StandardError => e
      sync.failed!
      reschedule(ore_id)
      Sentry.capture_exception(e)
    else
      sync.ok!
    end
  end

  def reschedule(ore_id)
    self.class.set(wait: wait_to_perform(ore_id)).perform_later(ore_id.id)
  end

  def wait_to_perform(ore_id)
    wait_time = ore_id.next_sync_allowed_after - Time.current
    wait_time.positive ? wait_time : 0
  end
end

class OreIdPasswordUpdateSyncJob < OreIdBaseJob
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
end

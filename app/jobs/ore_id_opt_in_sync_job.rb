class OreIdOptInSyncJob < OreIdBaseJob
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
      Sentry.capture_exception(e)
    else
      sync.ok!
    end
  end
end

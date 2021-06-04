class OreIdWalletBalanceSyncJob < OreIdBaseJob
  queue_as :default

  def perform(wallet_provision)
    return unless wallet_provision

    unless wallet_provision.sync_allowed?
      reschedule(wallet_provision)
      return
    end

    sync = wallet_provision.create_synchronisation

    begin
      wallet_provision.sync_balance
    rescue StandardError => e
      sync.failed!
      reschedule(wallet_provision)
      Sentry.capture_exception(e)
    else
      sync.ok!
    end
  end
end

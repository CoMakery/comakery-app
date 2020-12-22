class OreIdWalletOptInTxCreateJob < ApplicationJob
  queue_as :default

  def perform(wallet_provision)
    unless wallet_provision.sync_allowed?
      reschedule(wallet_provision)
      return
    end

    sync = wallet_provision.create_synchronisation

    begin
      wallet_provision.create_opt_in_tx
    rescue StandardError => e
      sync.failed!
      reschedule(wallet_provision)
      raise e
    else
      sync.ok!
    end
  end

  def reschedule(wallet_provision)
    self.class.set(wait: wallet_provision.next_sync_allowed_after - Time.current).perform_later(wallet_provision)
  end
end

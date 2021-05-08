class SyncBalanceJob < ApplicationJob
  queue_as :low

  def perform(balance)
    return unless balance

    # NOTE: Do not raise job errors to avoid Sidekiq rescheduling
    begin
      balance.sync_with_blockchain! if balance.ready_for_balance_update?
    rescue StandardError => e
      Sentry.capture_exception(e)
    end
  end
end

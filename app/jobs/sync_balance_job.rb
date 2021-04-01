class SyncBalanceJob < ApplicationJob
  queue_as :low

  def perform(balance)
    return unless balance
    return if balance.updated_at < 10.seconds.ago

    balance.sync_with_blockchain!
  end
end

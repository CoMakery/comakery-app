class SyncBalanceJob < ApplicationJob
  queue_as :low

  def perform(balance)
    return unless balance

    balance.sync_with_blockchain! if balance.ready_for_balance_update?
  end
end

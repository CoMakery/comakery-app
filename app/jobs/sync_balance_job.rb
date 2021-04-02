class SyncBalanceJob < ApplicationJob
  queue_as :low

  def perform(balance)
    return unless balance
    # Do not update if it was updated recently but should be updated for just created balance
    return if balance.updated_at > balance.created_at && balance.updated_at > 10.seconds.ago

    balance.sync_with_blockchain!
  end
end

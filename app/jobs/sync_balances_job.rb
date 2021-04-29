class SyncBalancesJob < ApplicationJob
  queue_as :low

  def perform
    Balance.ready_for_balance_update.select(:id).find_each do |balance|
      SyncBalanceJob.perform_later(balance)
    end
  end
end

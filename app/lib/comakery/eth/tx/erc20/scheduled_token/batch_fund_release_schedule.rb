class Comakery::Eth::Tx::Erc20::ScheduledToken::BatchFundReleaseSchedule < Comakery::Eth::Tx::Erc20
  def method_name
    'batchFundReleaseSchedule'
  end

  def abi
    JSON.parse(File.read(Rails.root.join('vendor/abi/coin_types/lockup.json')))
  end

  def method_params
    [
      blockchain_transaction.destinations,
      blockchain_transaction.amounts,
      blockchain_transaction.commencement_dates,
      blockchain_transaction.lockup_schedule_ids
    ]
  end
end

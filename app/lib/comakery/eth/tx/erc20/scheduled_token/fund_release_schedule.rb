class Comakery::Eth::Tx::Erc20::ScheduledToken::FundReleaseSchedule < Comakery::Eth::Tx::Erc20
  def method_name
    'fundReleaseSchedule'
  end

  def abi
    JSON.parse(File.read(Rails.root.join('vendor/abi/coin_types/lockup.json')))
  end

  def method_params
    [
      blockchain_transaction.destination,
      blockchain_transaction.amount,
      blockchain_transaction.commencement_dates.first,
      blockchain_transaction.lockup_schedule_ids.first
    ]
  end
end

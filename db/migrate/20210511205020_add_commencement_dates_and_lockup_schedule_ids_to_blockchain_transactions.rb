class AddCommencementDatesAndLockupScheduleIdsToBlockchainTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :blockchain_transactions, :commencement_dates, :text, array: true, default: []
    add_column :blockchain_transactions, :lockup_schedule_ids, :text, array: true, default: []
  end
end

class MakeExistingAccountRecordsAndTransferRulesSynced < ActiveRecord::DataMigration
  def up
    AccountTokenRecord.find_each(&:synced!)
    TransferRule.find_each(&:synced!)
  end
end

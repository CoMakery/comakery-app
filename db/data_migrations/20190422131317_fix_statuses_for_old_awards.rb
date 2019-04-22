# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class FixStatusesForOldAwards < ActiveRecord::DataMigration
  def up
    Award.where.not(unit_amount: nil).each do |award|
      award.update_column(:status, (award.ethereum_transaction_address ? 'paid' : 'accepted'))
    end
  end
end

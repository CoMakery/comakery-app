# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations
# rubocop:disable Rails/Output

class FixAmountForLegacyAwards < ActiveRecord::DataMigration
  def up
    Award.where.not(quantity: 1).where('amount = total_amount').find_each do |award|
      if award.award_type.amount * award.quantity == award.total_amount
        award.update_column(:amount, award.award_type.amount)
      else
        puts "WARNING: Amount values are corrupted for Award ##{award.id}"
      end
    end
  end
end

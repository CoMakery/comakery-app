# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class PopulateNameAndAmountForLegacyAwards < ActiveRecord::DataMigration
  def up
    Award.where(name: nil, amount: nil).each do |award|
      award.update_column(:name, award.award_type&.name)
      award.update_column(:amount, award.total_amount)
    end
  end
end

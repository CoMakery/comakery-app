# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class PopulateStateForAwardTypes < ActiveRecord::DataMigration
  def up
    AwardType.all.each do |award_type|
      award_type.update_column(:state, award_type.published? ? :ready : :draft)
    end
  end
end

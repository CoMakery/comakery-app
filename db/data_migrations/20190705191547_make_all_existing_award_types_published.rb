# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class MakeAllExistingAwardTypesPublished < ActiveRecord::DataMigration
  def up
    AwardType.where(published: false).each do |award_type|
      award_type.update_column(:published, true)
    end
  end
end

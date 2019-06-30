# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class MoveSpecialtyReferenceFromAwardTypesToAwards < ActiveRecord::DataMigration
  def up
    AwardType.where.not(specialty_id: [nil, 0]).each do |award_type|
      award_type.awards.each do |award|
        award.update_column(:specialty_id, award_type.specialty_id)
      end
    end
  end
end

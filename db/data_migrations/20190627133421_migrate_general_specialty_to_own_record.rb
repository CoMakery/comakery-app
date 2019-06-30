# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class MigrateGeneralSpecialtyToOwnRecord < ActiveRecord::DataMigration
  def up
    Specialty.initializer_setup

    Award.where(specialty: nil).each do |award|
      award.update_column(:specialty_id, Specialty.find_by(name: 'General').id)
    end
  end
end

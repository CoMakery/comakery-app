# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class FillLongIdForAllProjects < ActiveRecord::DataMigration
  def up
    Project.where(long_id: nil).each { |project| project.update_column(:long_id, SecureRandom.hex(20)) }
  end
end

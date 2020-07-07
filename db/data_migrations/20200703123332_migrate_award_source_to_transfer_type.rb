# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class MigrateAwardSourceToTransferType < ActiveRecord::DataMigration
  def up
    Award.all.find_each do |award|
      award.update_column(:transfer_type_id, award.project.transfer_types.find_by(name: award.source).id)
    end
  end
end

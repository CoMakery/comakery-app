class CreateDefaultTransferTypes < ActiveRecord::DataMigration
  def up
    Project.all.find_each(&:create_default_transfer_types)
  end
end

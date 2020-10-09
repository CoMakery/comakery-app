class AddSpecialties < ActiveRecord::DataMigration
  def up
    Specialty.initializer_setup
  end
end

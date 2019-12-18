class AddProjectManagerSpecialty < ActiveRecord::DataMigration
  def up
    Specialty.find_or_create_by(name: 'Project Manager', id: 10)
  end
end

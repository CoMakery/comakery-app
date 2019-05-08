class RunProjectImagesConversion < ActiveRecord::DataMigration
  def up
    raise 'Migration task did not succeed' unless system('rake migration:update_project_images')
  end
end

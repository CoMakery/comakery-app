class RemoveMissionsCreatedByAutomation < ActiveRecord::DataMigration
  def up
    if Rails.env.production?
      name = Mission.arel_table[:name]
      Mission.where(name.matches('%Automation%')).destroy_all
    end
  end
end

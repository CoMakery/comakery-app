class PopulateProjectInterestedCounterCache < ActiveRecord::DataMigration
  def up
    Project.find_each do |project|
      Project.reset_counters(project.id, :interests)
    end
  end
end

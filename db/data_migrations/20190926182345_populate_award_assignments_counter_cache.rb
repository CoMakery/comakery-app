class PopulateAwardAssignmentsCounterCache < ActiveRecord::DataMigration
  def up
    Award.find_each do |award|
      Award.reset_counters(award.id, :assignments)
    end
  end
end

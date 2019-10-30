class RemoveDuplicatedInterests < ActiveRecord::DataMigration
  def up
    Project.find_each do |project|
      project.interests.where.not(id: project.interests.group(:account_id).select('min(interests.id)')).delete_all
    end
  end
end

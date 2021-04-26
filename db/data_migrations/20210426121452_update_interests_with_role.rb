class UpdateInterestsWithRole < ActiveRecord::DataMigration
  def up
    Project.find_each do |project|
      Interest
        .where(project: project, account_id: project.admins.pluck(:id) | [project.account.id])
        .update_all(role: :admin)
    end
  end
end

class UpdateInterestsWithRole < ActiveRecord::DataMigration
  def up
    Project.find_each do |project|
      Interest
        .where(project: project, account_id: project.admins.pluck(:id) | [project.account.id])
        .find_each { |interest| interest.update(role: :admin) }
    end
  end
end

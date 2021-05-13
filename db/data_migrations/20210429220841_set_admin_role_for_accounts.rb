class SetAdminRoleForAccounts < ActiveRecord::DataMigration
  def up
    Project.find_each do |project|
      ProjectRole
        .where(project: project, account_id: project.admins.pluck(:id) | [project.account_id])
        .find_each { |role| role.update(role: :admin) }
    end
  end
end

class UpdateProjectRolesCounter < ActiveRecord::DataMigration
  def up
    execute <<-SQL.squish
        UPDATE projects
           SET project_roles_count = (SELECT count(1)
                                        FROM project_roles
                                       WHERE project_roles.project_id = projects.id)
    SQL
  end
end

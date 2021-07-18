class ProjectRoleDecorator < Draper::Decorator
  delegate_all

  def self.roles_pretty
    {
      'interested' => 'Project Member',
      'admin' => 'Admin',
      'observer' => 'Read Only Admin'
    }
  end

  def self.role_options_for_select
    ProjectRole.roles.keys.map do |role|
      [
        roles_pretty[role],
        role
      ]
    end
  end

  def role_pretty
    self.class.roles_pretty[role]
  end
end

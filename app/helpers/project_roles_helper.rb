module ProjectRolesHelper
  def role_options_for_select
    ProjectRole.roles.keys.map do |role|
      [
        ProjectRole::HUMANIZED_ROLE_NAMES[role.to_sym],
        role
      ]
    end
  end
end

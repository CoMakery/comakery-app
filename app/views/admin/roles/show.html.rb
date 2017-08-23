class Views::Admin::Roles::Show < Views::Base
  needs :role

  def content
    full_row do
      p do
        text 'Name: '
        text(role.name)
      end
      p do
        text 'Key: '
        text(role.key)
      end

      p do
        link_to 'Edit', edit_admin_role_path(role)
        text ' | '
        link_to 'Back', admin_roles_path
      end
    end
  end
end

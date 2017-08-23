class Views::Admin::Roles::Index < Views::Base
  needs :roles

  def content
    full_row do
      h1('Listing roles')

      table do
        thead do
          tr do
            th('Name')
            th('Key')
            th(colspan: '3')
          end
        end

        tbody do
          roles.each do |role|
            tr do
              td(role.name)
              td(role.key)
              td { link_to 'Show', admin_role_path(role) }
              td { link_to 'Edit', edit_admin_role_path(role) }
              td { link_to 'Destroy', admin_role_path(role), method: :delete, data: { confirm: 'Are you sure?' } }
            end
          end
        end
      end

      p do
        link_to 'New Role', new_admin_role_path, class: buttonish
      end
      p do
        link_to 'Back', admin_path
      end
    end
  end
end

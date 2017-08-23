class Views::Admin::Accounts::Index < Views::Base
  needs :accounts

  def content
    full_row do
      h1('Listing accounts')

      p do
        text 'Found '
        text(accounts.length)
        text ' accounts.'
      end
      table do
        thead do
          tr do
            th('E-mail')
            th('Roles')
            th(colspan: '3')
          end
        end

        tbody do
          accounts.each do |account|
            tr do
              td(account.email)
              td(account.roles.map(&:name).join(', '))
              td do
                link_to 'Show', admin_account_path(account)
              end

              td do
                link_to 'Edit', edit_admin_account_path(account)
              end

              td do
                link_to 'Destroy', admin_account_path(account), method: :delete, data: { confirm: 'Are you sure?' }
              end
            end
          end
        end
      end

      p do
        link_to 'New Account', new_admin_account_path, class: buttonish
      end
      p do
        link_to 'Back', admin_path
      end
    end
  end
end

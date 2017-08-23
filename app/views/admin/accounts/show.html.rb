class Views::Admin::Accounts::Show < Views::Base
  needs :account

  def content
    full_row do
      p do
        text 'E-mail: '
        text(account.email)
      end
      p do
        text 'Roles: '
        text(account.roles.map(&:name).join(', '))
      end
      p do
        link_to 'Edit', edit_admin_account_path(account)
        text ' | '
        link_to 'Back', admin_accounts_path
      end
    end
  end
end

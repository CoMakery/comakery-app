class Views::Admin::Accounts::Form < Views::Base
  needs :account
  needs :roles

  def content
    form_for([:admin, account]) do |f|
      with_errors(account, :email) do
        label do
          text 'E-mail: '
          f.text_field :email
        end
      end

      if account.new_record?
        with_errors(account, :password) do
          label do
            text 'Password: '
            f.password_field :password
          end
        end
      end

      full_row do
        label('Roles: ')
        f.collection_check_boxes :role_ids, roles, :id, :name
      end

      div(class: 'actions') do
        f.submit class: buttonish
      end
    end
  end
end

class Views::Accounts::New < Views::Base
  needs :account

  def content
    row do
      column(%i[small-12 large-6], class: 'large-centered') do
        h1('Signup')

        form_for account do |f|
          row do
            column('large-12') do
              with_errors(account, :email) do
                label do
                  text 'E-mail: '
                  f.text_field :email
                end
              end
            end

            column('large-12') do
              with_errors(account, :password) do
                label do
                  text 'Password: '
                  f.password_field :password
                end
              end
            end

            column('large-12') do
              f.submit class: buttonish(:medium)
            end
          end
        end
      end
    end
  end
end

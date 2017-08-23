module Views
  module PasswordResets
    class Edit < Views::Base
      needs :account
      needs :token

      def content
        # TODO: this is nearly identical to Views::AccountClaims::Edit. Definitely refactor if it's similar to change-password.
        row do
          column('medium-6', class: 'medium-centered') do
            h2('Set a password')
            form_for account, url: password_reset_path(token), html: { method: :put } do |f|
              row do
                column do
                  label do
                    text 'Email '
                    f.text_field :email, disabled: true
                  end
                end
              end
              row do
                column do
                  with_errors(f.object, :password) do
                    label do
                      text 'Password '
                      f.password_field :password
                    end
                  end
                end
              end
              row do
                column do
                  f.submit 'Save', class: buttonish(:small, :expand)
                end
              end
            end
          end
        end
      end
    end
  end
end

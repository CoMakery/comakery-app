module Views
  module Accounts
    class Edit < Views::Base
      needs :account

      def content
        row do
          column('large-6') do
            h2('Account Profile')

            p do
              text 'Email: '
              text account.email
            end

            h4('Change Password')

            form_for account do |f|
              with_errors(account, :old_password) do
                label do
                  text 'Old Password '
                  f.password_field :old_password
                end
              end
              with_errors(account, :password) do
                label do
                  text 'New Password '
                  f.password_field :password
                end
              end
              f.submit 'Change', class: buttonish(:small, :expand)
            end
          end
        end
      end
    end
  end
end

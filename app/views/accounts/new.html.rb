class Views::Accounts::New < Views::Base
  use_instance_variables_for_assigns true
  needs :whitelabel_mission
  needs :account

  def content
    row do
      column(%i[small-12 large-6], class: 'large-centered') do
        h1('Sign Up With Email')

        form_for account do |f|
          row do
            column('large-12') do
              with_errors(account, :email) do
                label do
                  f.text_field :email, tabindex: 1, type: 'email', placeholder: 'Email'
                end
              end
            end

            column('large-12') do
              with_errors(account, :password) do
                label do
                  f.password_field :password, tabindex: 2, placeholder: 'Password'
                end
              end
            end

            column('large-12 agreement') do
              unless @whitelabel_mission
                with_errors(account, :agreed_to_user_agreement) do
                  label do
                    f.check_box :agreed_to_user_agreement

                    span do
                      text 'I agree to the '
                      link_to 'CoMakery User Agreement', '/user-agreement'
                      text ' and '
                      link_to 'Privacy Policy terms', '/privacy-policy'
                    end
                  end
                end
              end

              f.submit 'Create Your Account', class: buttonish(:medium), style: 'margin: 0'
            end
          end
        end

        render partial: 'shared/auth' unless @whitelabel_mission
      end
    end
  end
end

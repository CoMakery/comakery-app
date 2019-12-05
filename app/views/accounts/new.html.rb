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

        unless @whitelabel_mission
          column('large-12 no-h-pad', style: 'margin-top: 30px') do
            h3 'Or Sign Up With'
          end

          column('large-12 no-h-pad', style: 'margin-top: 10px') do
            link_to 'javascript:void(0)', class: 'auth-button metamask signin-with-metamask' do
              span 'MetaMask'
            end
          end

          column('large-12 no-h-pad', style: 'margin-top: 10px') do
            link_to '/auth/slack', method: :post, class: 'auth-button slack' do
              text 'Slack'
            end
          end

          column('large-12 no-h-pad', style: 'margin-top: 10px') do
            link_to login_discord_path, method: :post, class: 'auth-button discord' do
              text 'Discord'
            end
          end

          column('large-12 no-h-pad', style: 'margin-top: 10px') do
            label do
              text 'By clicking a button to Sign Up with Slack, Metamask or Discord, you are agreeing to the '
              link_to 'CoMakery User Agreement', '/user-agreement'
              text ' and '
              link_to 'Privacy Policy Terms', '/privacy-policy'
            end
          end
        end
      end
    end
    render 'sessions/metamask_modal'
  end
end

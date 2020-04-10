class Views::Sessions::New < Views::Base
  use_instance_variables_for_assigns true
  needs :whitelabel_mission

  def content
    row do
      column(%i[small-12 medium-8 large-6], class: 'large-centered') do
        if whitelabel_mission
          h1("Sign In To #{whitelabel_mission.name} Platform", style: 'text-align: center')
        else
          h1('Sign In')
        end

        form_tag sign_in_session_path, method: 'post' do
          row do
            column('large-12') do
              label do
                text_field_tag :email, nil, tabindex: 1, type: 'email', placeholder: 'Email'
              end

              label(style: 'text-align: right') do
                password_field_tag :password, nil, tabindex: 2, placeholder: 'Password'
                link_to 'Forgot Password?', new_password_reset_path
              end
              submit_tag 'Sign In', class: buttonish(:medium), tabindex: 3
            end
          end
        end

        unless whitelabel_mission
          column('large-12 no-h-pad', style: 'margin-top: 20px') do
            h3(style: 'font-size: 26px;') { text 'Or You Can' }
          end

          # NOTE: Disable until security issue is fixed
          #
          # column('large-12 no-h-pad', style: 'margin-top: 5px') do
          #   link_to 'javascript:void(0)', class: 'auth-button metamask signin-with-metamask' do
          #     span 'Sign in with MetaMask'
          #   end
          # end

          column('large-12 no-h-pad', style: 'margin-top: 20px') do
            link_to '/auth/slack', method: :post, class: 'auth-button slack' do
              text 'Sign in with Slack'
            end
          end

          column('large-12 no-h-pad', style: 'margin-top: 20px') do
            link_to login_discord_path, method: :post, class: 'auth-button discord' do
              text 'Sign in with Discord'
            end
          end
        end
      end
    end
    render 'metamask_modal'
  end
end

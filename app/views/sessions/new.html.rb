class Views::Sessions::New < Views::Base
  def content
    row do
      column(%i[small-12 medium-8 large-6], class: 'large-centered', style: 'min-width: 543px') do
        h1('Sign In')

        form_tag sign_in_session_path, method: 'post' do
          row do
            column('large-12') do
              label do
                text 'E-mail: '
                text_field_tag :email, nil, tabindex: 1, type: 'email'
              end
              label do
                text 'Password: '
                link_to 'Forgot?', new_password_reset_path
                password_field_tag :password, nil, tabindex: 2
              end
              submit_tag 'SIGN IN WITH EMAIL', class: buttonish(:medium), style: 'margin: 0', tabindex: 3
            end
          end
        end
        column('large-12 no-h-pad', style: 'margin-top: 20px') do
          h3(style: 'font-size: 26px;') { text 'Or You Can' }
        end
        column('large-12 no-h-pad', style: 'margin-top: 5px') do
          link_to 'javascript:void(0)', class: 'auth-button metamask signin-with-metamask' do
            span 'Sigin in with MetaMask'
          end
        end
        column('large-12 no-h-pad', style: 'margin-top: 20px') do
          link_to '/auth/slack', class: 'auth-button slack' do
            text 'Sign in with Slack'
          end
        end
        column('large-12 no-h-pad', style: 'margin-top: 20px') do
          link_to login_discord_path, class: 'auth-button discord' do
            text 'Sign in with Discord'
          end
        end
      end
    end
    render 'metamask_modal'
  end
end

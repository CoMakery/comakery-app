class Views::Sessions::New < Views::Base
  def content
    row {
      column(%i[small-12 medium-8 large-6], class: 'large-centered', style: 'min-width: 543px') {
        h1('Sign In')

        form_tag sign_in_session_path, method: 'post' do
          row {
            column('large-12') {
              label {
                text 'E-mail: '
                text_field_tag :email, nil, tabindex: 1, type: 'email'
              }
              label {
                text 'Password: '
                link_to 'Forgot?', new_password_reset_path
                password_field_tag :password, nil, tabindex: 2
              }
              submit_tag 'Sign In With Email', class: buttonish(:medium), style: 'margin: 0', tabindex: 3
            }
          }
        end
        column('large-12 no-h-pad', style: 'margin-top: 20px') {
          h3(style: 'font-size: 26px;') { text 'Or You Can' }
        }
        column('large-12 no-h-pad', style: 'margin-top: 5px') {
          link_to 'javascript:void(0)', class: 'auth-button metamask signin-with-metamask' do
            span 'Sigin in with MetaMask'
          end
        }
        column('large-12 no-h-pad', style: 'margin-top: 20px') {
          link_to '/auth/slack', class: 'auth-button slack' do
            text 'Sign in with Slack'
          end
        }
        column('large-12 no-h-pad', style: 'margin-top: 20px') {
          link_to login_discord_path, class: 'auth-button discord' do
            text 'Sign in with Discord'
          end
        }
      }
    }
    render 'metamask_modal'
  end
end

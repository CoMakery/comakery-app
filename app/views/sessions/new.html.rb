class Views::Sessions::New < Views::Base
  def content
    row {
      column(%i[small-12 medium-8 large-6], class: 'large-centered', style: 'min-width: 543px') {
        h1('Sign in')

        form_tag sign_in_session_path, method: 'post' do
          row {
            column('large-12') {
              label {
                text 'E-mail: '
                text_field_tag :email, nil, tabindex: 1, type: 'email'
              }
              br
              label {
                text 'Password: '
                link_to 'Forgot?', new_password_reset_path
                password_field_tag :password, nil, tabindex: 2
              }
              br
              submit_tag 'Sign In', class: buttonish(:medium), style: 'margin: 0', tabindex: 3
            }
          }
        end
        column('large-12 no-h-pad', style: 'margin-top: 30px') {
          h3 'Or Sign In With'
        }
        column('large-12 no-h-pad', style: 'margin-top: 10px') {
          link_to 'javascript:void(0)', class: 'auth-button metamask signin-with-metamask' do
            span 'MetaMask'
          end
        }
        column('large-12 no-h-pad', style: 'margin-top: 10px') {
          link_to '/auth/slack', class: 'auth-button slack' do
            text 'Slack'
          end
        }
        column('large-12 no-h-pad', style: 'margin-top: 10px') {
          link_to login_discord_path, class: 'auth-button discord' do
            text 'Discord'
          end
        }
      }
    }
    render 'metamask_modal'
  end
end

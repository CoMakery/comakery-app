class Views::Sessions::New < Views::Base
  def content
    row {
      column(%i[small-12 large-6], class: 'large-centered') {
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
              submit_tag 'Sign In', class: buttonish(:medium), tabindex: 3
              link_to '/auth/slack', class: 'auth-button' do
                image_tag 'slack.png', style: 'height: 38px'
                text 'Sign in with Slack'
              end
              link_to login_discord_path, class: 'auth-button' do
                image_tag 'discord.png', style: 'height: 40px'
                text 'Sign in with Discord'
              end
              div(class: 'signin-with-metamask-wrapper') {
                link_to 'javascript:void(0)', class: 'auth-button signin-with-metamask' do
                  image_tag 'metamask.png', style: 'height: 28px'
                  text 'Sign in with MetaMask'
                end
              }
            }
          }
        end
      }
    }
  end
end

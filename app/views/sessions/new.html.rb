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
            }
          }
        end
      }
    }
  end
end

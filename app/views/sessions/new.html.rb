class Views::Sessions::New < Views::Base
  def content
    row do
      column(%i[small-12 large-6], class: 'large-centered') do
        h1('Sign in')

        form_tag session_path, method: 'post' do
          row do
            column('large-12') do
              label do
                text 'E-mail: '
                text_field_tag :email, nil, tabindex: 1, type: 'email'
              end
              br
              label do
                text 'Password: '
                link_to 'Forgot?', new_password_reset_path
                password_field_tag :password, nil, tabindex: 2
              end
              br
              submit_tag 'Sign In', class: buttonish(:medium), tabindex: 3
            end
          end
        end
      end
    end
  end
end

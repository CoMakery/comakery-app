class Views::Sessions::New < Views::Base
  use_instance_variables_for_assigns true
  needs :whitelabel_mission

  def content
    row do
      column(%i[small-12 medium-8 large-6], class: 'large-centered') do
        if whitelabel_mission
          h1("Sign In To #{whitelabel_mission.name} Platform", style: 'text-align: center')
        else
          h1('Sign In With Email')
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

        render partial: 'shared/auth' unless whitelabel_mission
      end
    end
  end
end

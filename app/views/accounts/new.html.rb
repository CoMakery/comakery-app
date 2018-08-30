class Views::Accounts::New < Views::Base
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
                  text 'E-mail: *'
                  f.email_field :email
                end
              end
            end

            column('large-12') do
              with_errors(account, :first_name) do
                label do
                  text 'First Name: *'
                  f.text_field :first_name
                end
              end
            end

            column('large-12') do
              with_errors(account, :last_name) do
                label do
                  text 'Last Name: *'
                  f.text_field :last_name
                end
              end
            end

            column('large-12') do
              with_errors(account, :nickname) do
                label do
                  text 'Nickname: '
                  f.text_field :nickname
                end
              end
            end

            column('large-12') do
              with_errors(account, :date_of_birth) do
                label do
                  text 'Date of Birth: *'
                  f.text_field :date_of_birth, placeholder: 'mm/dd/yyyy', class: 'datepicker'
                end
              end
            end

            column('large-12') do
              f.object.country ||= 'United States of America'
              with_errors(account, :country) do
                label do
                  text 'Country: *'
                  f.select :country, Country.all.sort
                end
              end
            end

            column('large-12') do
              with_errors(account, :password) do
                label do
                  text 'Password: *'
                  f.password_field :password
                end
              end
            end

            column('large-12') do
              f.submit 'CREATE YOUR ACCOUNT', class: buttonish(:medium), style: 'margin: 0'
            end
          end
        end
        column('large-12 no-h-pad', style: 'margin-top: 30px') do
          h3 'Or Sign Up With'
        end
        column('large-12 no-h-pad', style: 'margin-top: 10px') do
          link_to 'javascript:void(0)', class: 'auth-button metamask signin-with-metamask' do
            span 'MetaMask'
          end
        end
        column('large-12 no-h-pad', style: 'margin-top: 10px') do
          link_to '/auth/slack', class: 'auth-button slack' do
            text 'Slack'
          end
        end
        column('large-12 no-h-pad', style: 'margin-top: 10px') do
          link_to login_discord_path, class: 'auth-button discord' do
            text 'Discord'
          end
        end
      end
    end
    render 'sessions/metamask_modal'
  end
end

class Views::Accounts::New < Views::Base
  needs :account

  def content
    row {
      column(%i[small-12 large-6], class: 'large-centered') {
        h1('Signup')

        form_for account do |f|
          row {
            column('large-12') {
              with_errors(account, :email) {
                label {
                  text 'E-mail: *'
                  f.email_field :email
                }
              }
            }

            column('large-12') {
              with_errors(account, :first_name) {
                label {
                  text 'First Name: *'
                  f.text_field :first_name
                }
              }
            }

            column('large-12') {
              with_errors(account, :last_name) {
                label {
                  text 'Last Name: *'
                  f.text_field :last_name
                }
              }
            }

            column('large-12') {
              with_errors(account, :nickname) {
                label {
                  text 'Nickname: '
                  f.text_field :nickname
                }
              }
            }

            column('large-12') {
              with_errors(account, :date_of_birth) {
                label {
                  text 'Date of Birth: *'
                  f.text_field :date_of_birth, placeholder: 'mm/dd/yyyy', class: 'datepicker'
                }
              }
            }

            column('large-12') {
              f.object.country ||= 'United States of America'
              with_errors(account, :country) {
                label {
                  text 'Country: *'
                  f.select :country, Country.all.sort
                }
              }
            }

            column('large-12') {
              with_errors(account, :password) {
                label {
                  text 'Password: *'
                  f.password_field :password
                }
              }
            }

            column('large-12') {
              f.submit class: buttonish(:medium)
            }
            column('large-12', style: 'margin-top: 10px') {
              link_to '/auth/slack', class: 'auth-button' do
                image_tag 'slack.png', style: 'height: 38px'
                text 'Sign up with Slack'
              end
              link_to login_discord_path, class: 'auth-button' do
                image_tag 'discord.png', style: 'height: 40px'
                text 'Sign up with Discord'
              end
            }
            column('large-12', style: 'margin-top: 10px') {
              div(class: 'signin-with-metamask-wrapper') {
                link_to 'javascript:void(0)', class: 'auth-button signin-with-metamask' do
                  image_tag 'metamask.png', style: 'height: 28px'
                  span 'Sign up with MetaMask'
                end
              }
            }
          }
        end
      }
    }
    render 'sessions/metamask_modal'
  end
end

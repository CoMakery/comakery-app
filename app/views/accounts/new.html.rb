class Views::Accounts::New < Views::Base
  needs :account

  def content
    row {
      column(%i[small-12 large-6], class: 'large-centered') {
        h1('Sign Up With Email')

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
              f.submit 'Create Your Account', class: buttonish(:medium), style: 'margin: 0'
            }
          }
        end
        column('large-12 no-h-pad', style: 'margin-top: 30px') {
          h3 'Or Sign Up With'
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
    render 'sessions/metamask_modal'
  end
end

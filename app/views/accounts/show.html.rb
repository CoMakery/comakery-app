class Views::Accounts::Show < Views::Base
  needs :current_account

  def content
    div(class: 'ethereum_wallet', style: 'margin-top: 10px;') {
      div(class: 'hide edit-ethereum-wallet') {
        h4(style: 'border: none;') {
          text 'Account Detail ('
          a(href: '#', "data-toggles": '.edit-ethereum-wallet,.view-ethereum-wallet') { text 'Cancel' }
          text ')'
        }
        row {
          form_for current_account, url: '/account' do |f|
            column('small-3') {
              label(for: :email) {
                text 'Email'
              }
            }
            column('small-9') {
              with_errors(current_account, :email) {
                f.email_field :email
              }
            }

            column('small-3') {
              label(for: :first_name) {
                text 'First Name'
              }
            }
            column('small-9') {
              with_errors(current_account, :first_name) {
                f.text_field :first_name
              }
            }

            column('small-3') {
              label(for: :last_name) {
                text 'Last Name'
              }
            }
            column('small-9') {
              with_errors(current_account, :last_name) {
                f.text_field :last_name
              }
            }

            column('small-3') {
              label(for: :nickname) {
                text 'Nickname'
              }
            }
            column('small-9') {
              with_errors(current_account, :nickname) {
                f.text_field :nickname
              }
            }

            column('small-3') {
              label(for: :account_date_of_birth) {
                text 'Date of Birth'
              }
            }
            column('small-9') {
              with_errors(current_account, :date_of_birth) {
                f.text_field :date_of_birth, class: 'datepicker', placeholder: 'mm/dd/yyyy', value: f.object.date_of_birth&.strftime('%m/%d/%Y')
              }
            }

            column('small-3') {
              label(for: :country) {
                text 'Country'
              }
            }
            column('small-9') {
              with_errors(current_account, :country) {
                f.select :country, Country.all.sort, prompt: 'select country'
              }
            }

            column('small-3') {
              label(for: :account_ethereum_wallet) {
                text 'Ethereum Address'
              }
            }
            column('small-9') {
              with_errors(current_account, :ethereum_wallet) {
                f.text_field :ethereum_wallet
              }
            }

            column('small-3') {
              label(for: :image) {
                text 'Image'
              }
            }
            column('small-9') {
              with_errors(current_account, :image) {
                f.file_field :image
              }
            }

            column('small-12 text-right') {
              f.submit 'Save', class: 'button'
            }
          end
        }
      }
      div(class: 'view-ethereum-wallet') {
        column('medium-12 large-9') {
          h4(style: 'border: none;') {
            text 'Account Details ('
            a(href: '#', "data-toggles": '.edit-ethereum-wallet,.view-ethereum-wallet') { text 'Edit' }
            text ')'
          }
          row {
            column('small-3') {
              text 'Email'
            }
            column('small-9') {
              text current_account.email
            }
          }
          row {
            column('small-3') {
              text 'First Name'
            }
            column('small-9') {
              text current_account.first_name
            }
          }
          row {
            column('small-3') {
              text 'Last Name'
            }
            column('small-9') {
              text current_account.last_name
            }
          }
          row {
            column('small-3') {
              text 'Nickname'
            }
            column('small-9') {
              text current_account.nickname
            }
          }
          row {
            column('small-3') {
              text 'Date of Birth'
            }
            column('small-9') {
              text current_account.date_of_birth.strftime('%m/%d/%Y') if current_account.date_of_birth
            }
          }
          row {
            column('small-3') {
              text 'Country'
            }
            column('small-9') {
              text current_account.country
            }
          }
          row {
            column('medium-3', style: 'margin-top: 8px;') {
              text 'Ethereum Address'
            }
            column('medium-9') {
              text_field_tag :ethereum_wallet, current_account.ethereum_wallet, class: 'copy-source', style: 'border: none; box-shadow: unset; padding: 2px 0; display: unset; width: 390px;'
              a(class: 'copiable', style: 'padding: 3px; border: 1px solid #ccc; margin-top: -3px;') {
                image_tag 'Octicons-clippy.png', size: '20x20'
              }
            }
          }
        }

        column('medium-12 large-3') {
          row {
            if current_account.image.present?
              image_tag attachment_url(current_account, :image, :fill, 130, 130), style: 'margin: 10px;'
            end
          }
        }
      }

      column('small-12', style: 'padding: 10px 0') {
        column('small-12') {
          link_to 'Download My Data', download_data_accounts_path(format: :zip)
        }
      }
    }

    hr

    current_account.awards.group_by { |award| award.project.id }.each do |(_, awards_for_project)|
      project = awards_for_project.first.project.decorate
      h3 {
        link_to project.title, project_awards_path(project)
      }
      render partial: 'shared/awards', locals: {
        awards: AwardDecorator.decorate_collection(awards_for_project),
        show_recipient: false,
        project: project
      }
    end
  end
end

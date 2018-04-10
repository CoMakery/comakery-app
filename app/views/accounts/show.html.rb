class Views::Accounts::Show < Views::Base
  needs :current_account

  def content
    div(class: 'ethereum_wallet') {
      div(class: 'hide edit-ethereum-wallet') {
        h4(style: 'border: none;') {
          text 'Account Detail ('
          a(href: '#', "data-toggles": '.edit-ethereum-wallet,.view-ethereum-wallet') { text 'Cancel' }
          text ')'
        }
        row {
          form_for current_account, url: '/account' do |f|
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
        column('small-7 medium-5') {
          h4(style: 'border: none;') {
            text 'Account Details ('
            a(href: '#', "data-toggles": '.edit-ethereum-wallet,.view-ethereum-wallet') { text 'Edit' }
            text ')'
          }
          row {
            column('small-4') {
              text 'First Name'
            }
            column('small-8') {
              text current_account.first_name
            }
          }
          row {
            column('small-4') {
              text 'Last Name'
            }
            column('small-8') {
              text current_account.last_name
            }
          }
          row {
            column('small-4') {
              text 'Nickname'
            }
            column('small-8') {
              text current_account.nickname
            }
          }
          row {
            column('small-4') {
              text 'Ethereum Address'
            }
            column('small-8') {
              text current_account.ethereum_wallet
            }
          }
        }
        column('small-5 medium-7') {
          row {
            if current_account.image.present?
              image_tag attachment_url(current_account, :image, :fill, 130, 130), style: 'margin: 10px;'
            end
          }
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

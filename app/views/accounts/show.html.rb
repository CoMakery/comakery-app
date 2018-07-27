class Views::Accounts::Show < Views::Base
  needs :current_account

  def content
    div(class: 'ethereum_wallet', style: 'margin-top: 10px;') do
      div(class: 'hide edit-ethereum-wallet') do
        h4(style: 'border: none;') do
          text 'Account Detail ('
          a(href: '#', "data-toggles": '.edit-ethereum-wallet,.view-ethereum-wallet') { text 'Cancel' }
          text ')'
        end
        row do
          form_for current_account, url: '/account' do |f|
            column('small-3') do
              label(for: :email) do
                text 'Email'
              end
            end
            column('small-9') do
              with_errors(current_account, :email) do
                f.email_field :email
              end
            end

            column('small-3') do
              label(for: :first_name) do
                text 'First Name'
              end
            end
            column('small-9') do
              with_errors(current_account, :first_name) do
                f.text_field :first_name
              end
            end

            column('small-3') do
              label(for: :last_name) do
                text 'Last Name'
              end
            end
            column('small-9') do
              with_errors(current_account, :last_name) do
                f.text_field :last_name
              end
            end

            column('small-3') do
              label(for: :nickname) do
                text 'Nickname'
              end
            end
            column('small-9') do
              with_errors(current_account, :nickname) do
                f.text_field :nickname
              end
            end

            column('small-3') do
              label(for: :account_date_of_birth) do
                text 'Date of Birth'
              end
            end
            column('small-9') do
              with_errors(current_account, :date_of_birth) do
                f.text_field :date_of_birth, class: 'datepicker', placeholder: 'mm/dd/yyyy', value: f.object.date_of_birth&.strftime('%m/%d/%Y')
              end
            end

            column('small-3') do
              label(for: :country) do
                text 'Country'
              end
            end
            column('small-9') do
              with_errors(current_account, :country) do
                f.select :country, Country.all.sort, prompt: 'select country'
              end
            end

            column('small-3') do
              label(for: :account_ethereum_wallet) do
                text 'Ethereum Address'
              end
            end
            column('small-9') do
              with_errors(current_account, :ethereum_wallet) do
                f.text_field :ethereum_wallet
              end
            end

            column('small-3') do
              label(for: :image) do
                text 'Image'
              end
            end
            column('small-9') do
              with_errors(current_account, :image) do
                f.file_field :image
              end
            end

            column('small-12 text-right') do
              f.submit 'Save', class: 'button'
            end
          end
        end
      end
      div(class: 'view-ethereum-wallet') do
        column('medium-12 large-9') do
          h4(style: 'border: none;') do
            text 'Account Details ('
            a(href: '#', "data-toggles": '.edit-ethereum-wallet,.view-ethereum-wallet') { text 'Edit' }
            text ')'
          end
          row do
            column('small-3') do
              text 'Email'
            end
            column('small-9') do
              text current_account.email
            end
          end
          row do
            column('small-3') do
              text 'First Name'
            end
            column('small-9') do
              text current_account.first_name
            end
          end
          row do
            column('small-3') do
              text 'Last Name'
            end
            column('small-9') do
              text current_account.last_name
            end
          end
          row do
            column('small-3') do
              text 'Nickname'
            end
            column('small-9') do
              text current_account.nickname
            end
          end
          row do
            column('small-3') do
              text 'Date of Birth'
            end
            column('small-9') do
              text current_account.date_of_birth.strftime('%m/%d/%Y') if current_account.date_of_birth
            end
          end
          row do
            column('small-3') do
              text 'Country'
            end
            column('small-9') do
              text current_account.country
            end
          end
          row do
            column('medium-3', style: 'margin-top: 8px;') do
              text 'Ethereum Address'
            end
            column('medium-9') do
              text_field_tag :ethereum_wallet, current_account.ethereum_wallet, class: 'copy-source', style: 'border: none; box-shadow: unset; padding: 2px 0; display: unset; width: 390px;'
              a(class: 'copiable', style: 'padding: 3px; border: 1px solid #ccc; margin-top: -3px;') do
                image_tag 'Octicons-clippy.png', size: '20x20'
              end
            end
          end
        end

        column('medium-12 large-3') do
          row do
            if current_account.image.present?
              image_tag attachment_url(current_account, :image, :fill, 130, 130), style: 'margin: 10px;'
            end
          end
        end
      end

      column('small-12', style: 'padding: 10px 0') do
        column('small-12') do
          link_to 'Download My Data', download_data_accounts_path(format: :zip)
        end
      end
    end

    hr

    current_account.awards.group_by { |award| award.project.id }.each do |(_, awards_for_project)|
      project = awards_for_project.first.project.decorate
      h3 do
        link_to project.title, project_awards_path(project)
      end
      render partial: 'shared/awards', locals: {
        awards: AwardDecorator.decorate_collection(awards_for_project),
        show_recipient: false,
        project: project
      }
    end
  end
end

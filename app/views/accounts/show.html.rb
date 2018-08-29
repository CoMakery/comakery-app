class Views::Accounts::Show < Views::Base
  needs :current_account, :projects, :awards

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
        column('medium-12 large-9 no-h-pad') do
          h4(style: 'border: none;') do
            text 'Account Details '
            a(href: 'javascript:;', id: 'toggle-edit') do
              i(class: 'fa fa-cog', "data-toggles": '.edit-ethereum-wallet,.view-ethereum-wallet')
            end
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
              if current_account.ethereum_wallet.present?
                text_field_tag :ethereum_wallet, current_account.ethereum_wallet, class: 'fake-link copy-source', style: 'border: none; box-shadow: unset; padding: 2px 0; display: unset; width: 390px; cursor: pointer; background-color: unset;', readonly: true, data: { href: current_account.decorate.etherscan_address }
                a(class: 'copiable', style: 'padding: 3px; border: 1px solid #ccc; margin-top: -3px;') do
                  image_tag 'Octicons-clippy.png', size: '20x20'
                end
              end
            end
          end
        end

        column('medium-12 large-3 text-right') do
          row do
            column('small-12 no-h-pad'){
              link_to download_data_accounts_path(format: :zip) do
                text 'Download My Data '
                i(class: 'fa fa-download')
              end
            }
            if current_account.image.present?
              image_tag attachment_url(current_account, :image, :fill, 190, 190), style: 'margin-top: 10px;'
            end
          end
        end
      end
    end
    award_summary
    awards_table
  end

  def award_summary
    column('medium-12 no-h-pad') do
      h4(style: 'border: none;') do
        text 'Award Summary'
      end
      div(class: 'table-scroll table-box', style: 'margin-right: 0; min-width: 100%') do
        table(class: 'award-rows', style: 'min-width: 100%') do
          tr(class: 'header-row') do
            th(class: 'small-4') { text 'Project' }
            th(class: 'small-1') { text 'Token' }
            th(class: 'small-2') { text 'Total Awarded' }
            th(class: 'small-5') { text 'Token Contract Address' }
          end

          projects.each do |project, _awards|
            project = project.decorate
            tr(class: 'award-row') do
              td(class: 'small-4') do
                link_to project.title, project_awards_path(project.show_id, mine: true)
              end
              td(class: 'small-1') do
                text project.token_symbol || 'pending'
              end
              td(class: 'small-2') do
                text project.total_awarded_to_user(current_account)
              end
              td(class: 'small-5') do
                if project.ethereum_contract_address
                  link_to project.ethereum_contract_address, project.ethereum_contract_explorer_url
                else
                  text 'pending'
                end
              end
            end
          end
        end
      end
    end
  end

  def awards_table
    column('medium-12 no-h-pad') do
      h4(style: 'border: none;') do
        text 'Awards'
      end

      project = awards.first&.project&.decorate
      render partial: 'awards', locals: {
        awards: AwardDecorator.decorate_collection(awards),
        project: project
      }
    end
    column('medium-12 no-h-pad text-right') do
      text paginate(awards)
    end
  end
end

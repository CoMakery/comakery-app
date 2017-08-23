class Views::Authentications::Show < Views::Base
  needs :current_account, :authentication, :awards

  def content
    p do
      text 'You can download an Ethereum wallet from '
      link_to('Ethereum.org', 'http://www.ethereum.org', target: '_blank')
      text ' to create an account. Enter your Ethereum account address below. '
      text 'Then you will receive your CoMakery awards in your Ethereum account!'
    end
    p do
      link_to('Get a wallet now', 'http://www.ethereum.org', target: '_blank', class: buttonish)
    end
    div(class: 'ethereum_wallet') do
      div(class: 'hide edit-ethereum-wallet') do
        row do
          form_for authentication.account, url: '/account' do |f|
            with_errors(current_account, :ethereum_wallet) do
              column('small-3') do
                label(for: :account_ethereum_wallet) do
                  text 'Ethereum Address ('
                  a(href: '#', "data-toggles": '.edit-ethereum-wallet,.view-ethereum-wallet') { text 'Cancel' }
                  text ')'
                end
              end
              column('small-6') do
                f.text_field :ethereum_wallet
              end
              column('small-3') do
                f.submit 'Save'
              end
            end
          end
        end
      end
      div(class: 'view-ethereum-wallet') do
        row do
          column('small-3') do
            text 'Ethereum Address ('
            a(href: '#', "data-toggles": '.edit-ethereum-wallet,.view-ethereum-wallet') { text 'Edit' }
            text ')'
          end
          column('small-9') do
            # link_to authentication.account.ethereum_wallet, "https://www.etherchain.org/account/#{authentication.account.ethereum_wallet}", target: "_blank"
            text authentication.account.ethereum_wallet
          end
        end
      end
    end

    hr

    awards.group_by { |award| award.project.id }.each do |(_, awards_for_project)|
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

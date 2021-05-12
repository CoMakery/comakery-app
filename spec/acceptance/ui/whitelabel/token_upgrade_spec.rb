require 'rails_helper'

describe 'token upgrade from dummy erc20 to security token', type: :feature do
  let(:account) { create(:eth_wallet).account }

  context 'with project using dummy erc20 token' do
    let(:token) { create(:erc20_token) }
    let(:project) { create(:project, token: token) }

    before do
      login(project.account)
    end

    context 'and interested accounts' do
      before do
        project.add_account(account)
      end

      context 'on Accounts dashboard' do
        subject { visit project_dashboard_accounts_path(project) }

        it 'lists interested accounts' do
          subject

          expect(page).to have_css('.account-preview__info__name', count: 2)
        end
      end

      context 'after upgrade to security token' do
        let(:sec_token) { create(:comakery_token) }

        before do
          project.update!(token: sec_token)
          TransferType.create_defaults_for(project)
        end

        context 'on Accounts dashboard' do
          subject { visit project_dashboard_accounts_path(project) }

          it 'syncs account token records and lists interested accounts which have eth wallet' do
            subject

            VCR.use_cassette("infura/#{project.token._blockchain}/#{project.token.contract_address}/accounts") do
              click_button 'refresh accounts'
            end

            expect(page).to have_css('.account-preview__info__name', count: 1)
          end
        end

        context 'on Transfer Rules dashboard' do
          subject { visit project_dashboard_transfer_rules_path(project) }

          it 'syncs transfer rules and reg groups' do
            subject

            VCR.use_cassette("infura/#{project.token._blockchain}/#{project.token.contract_address}/filtered_logs") do
              click_button 'refresh transfer rules'
            end

            expect(page).to have_content '10 Groups'
            expect(page).to have_content '16 Rules'
          end
        end

        context 'on Transfers dashboard' do
          subject { visit project_dashboard_transfers_path(project) }

          before do
            create(:transfer, issuer: project.account, account: account, award_type: project.default_award_type)
          end

          it 'lists transfers' do
            subject

            expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1)
          end
        end
      end
    end
  end
end

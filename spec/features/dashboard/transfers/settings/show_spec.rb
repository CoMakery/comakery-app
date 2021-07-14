require 'rails_helper'

describe 'Transfer settings', js: true do
  let!(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }

  let(:project) { transfer.project }

  let(:account) { project.account }

  let(:open_settings) { first('.transfers-table__transfer__settings .dropdown > a').click }

  let(:dropdown_menu) { first('.transfers-table__transfer__settings .dropdown-menu') }

  context 'when account has permissions to settings' do
    before do
      login(account)

      visit project_dashboard_transfers_path(project)
    end

    it { expect(page).to have_css('.transfers-table__transfer__settings') }

    context 'and transfer is editable' do
      before do
        transfer.accepted!

        open_settings
      end

      it 'shows link to edit' do
        expect(dropdown_menu).to have_content('Edit')
      end
    end

    context 'and transfer is cancelable' do
      before do
        transfer.latest_blockchain_transaction.failed!

        open_settings
      end

      it 'shows link to cancel' do
        expect(dropdown_menu).to have_content('Cancel')
      end
    end

    context 'and transfer is accepted' do
      before { transfer.accepted! }

      context 'with failed transaction' do
        before do
          transfer.latest_blockchain_transaction.failed!

          open_settings
        end

        it 'does not show link to prioritize' do
          expect(dropdown_menu).not_to have_content('Prioritize')
        end
      end

      context 'and transaction with created or cancelled status' do
        before { transfer.latest_blockchain_transaction.created! }

        context 'without hot wallet' do
          before { open_settings }

          it { expect(dropdown_menu).not_to have_content('Prioritize') }
        end

        context 'with hot wallet' do
          let(:hot_wallet) { FactoryBot.create(:wallet) }

          before { project.update(hot_wallet: hot_wallet) }

          context 'and auto sending mode' do
            before do
              project.update(hot_wallet_mode: :auto_sending)

              open_settings
            end

            it { expect(dropdown_menu).to have_content('Prioritize') }
          end

          context 'and manual sending mode' do
            before do
              project.update(hot_wallet_mode: :manual_sending)

              open_settings
            end

            it { expect(dropdown_menu).to have_content('Pay by Hot Wallet') }
          end
        end
      end
    end
  end
end

require 'rails_helper'

describe 'Transfer form', js: true, skip: true do
  let(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }
  let(:project) { transfer.project }

  before do
    project.update!(visibility: :public_listed)
  end

  context 'when creating a new transfer' do
    before do
      login project.account
      visit project_dashboard_transfers_path(project)
    end

    subject { page }

    let(:open_dropdown) do
      find('.create-transfer').click
      find('.create-transfer-dropdown')
    end

    let(:open_form) do
      open_dropdown
      first('.create-transfer-dropdown .dropdown-item').click
      find('.create-transfer-form-skeleton')
      find('.create-transfer-form')
    end

    let(:create_transfer) do
      open_form

      execute_script "$('.account-search .choices')[0].click()"
      execute_script "$('.account-search input')[0].value = '#{transfer.account.first_name}'"
      execute_script "$('.account-search input')[0].dispatchEvent(new KeyboardEvent('keyup',{'key':'a'}))"

      first('.choices__item').click
      fill_in 'Amount', with: '100'
      execute_script "$('form.create-transfer-form')[0].submit()"

      find('div', text: 'Transfer Created')
    end

    let(:create_transfer_lockup) do
      open_form
      find('.account-search div.form-select').click
      fill_in 'Recepient Account', with: transfer.account.first_name
      find('.account-search div.form-select .choices-list.dropdown-menu .choices-item').click
      find('#account_wallets div.form-select').click
      find('#account_wallets div.form-select .choices-list.dropdown-menu .choices-item').click
      fill_in 'Amount', with: '100'
      fill_in 'Price', with: '2'
      find('label', text: 'Total Price: $200.00')
      select 'Bougth', from: 'Category'
      fill_in 'Commencement Date', with: '2021-06-01'
      fill_in 'Lockup Schedule', with: '1'
      click_button 'Create'
    end

    context 'and not logged in as an admin' do
      before do
        login create(:account)
        visit project_dashboard_transfers_path(project)
      end

      it { is_expected.not_to have_css('.create-transfer') }
    end

    context 'and managing categories' do
      before do
        open_dropdown
        click_link 'Manage Categories'
      end

      it { is_expected.to have_css('.reg-groups') }
    end

    context 'with an algorand token' do
      it 'creates a transfer' do
        expect { create_transfer }.to change { project.awards.count }.by(1)

        expect(project.awards.last.account).to eq(transfer.account)
        expect(project.awards.last.recepient_wallet).to eq(transfer.recepient_wallet)
        expect(project.awards.last.amount).to eq(100)
        expect(project.awards.last.transfer_type).to eq(project.transfer_types.find_by(name: 'bougth'))
      end
    end

    context 'with a lockup token' do
      context 'and having all the fields populated' do
      end

      context 'and having only required fields populated' do
      end
    end

    context 'without a token' do
    end
  end

  context 'when editing a transfer' do
    context 'and not logged in as an admin' do
    end

    context 'with an algorand token' do
      context 'and transfer is accepted' do
      end

      context 'and transfer is paid' do
      end

      context 'and transfer is cancelled' do
      end
    end

    context 'with a lockup token' do
    end
  end
end

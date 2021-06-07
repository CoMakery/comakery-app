require 'rails_helper'

describe 'Transfer form', js: true, skip: true do
  let(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }
  let(:project) { transfer.project }

  before do
    project.update!(visibility: :public_listed)
    login project.account
    visit project_dashboard_transfers_path(project)
  end

  subject { page }

  context 'when creating a new transfer' do
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

      find('.account-search .choices').click
      find('.account-search .choices').fill_in(with: transfer.account.first_name)
      first('.choices__item').click
      fill_in 'Amount', with: '100'
      click_button 'Create'

      find('div', text: 'Transfer Created')
    end

    let(:create_transfer_lockup) do
      open_form

      find('.account-search .choices').click
      find('.account-search .choices').fill_in(with: transfer.account.first_name)
      first('.choices__item').click
      fill_in 'Amount', with: '100'
      fill_in 'Price', with: '2'
      find('label', text: 'Total Price: $200.00')
      fill_in 'Commencement Date', with: '2021-06-01'
      fill_in 'Lockup Schedule', with: '1'
      click_button 'Create'

      find('div', text: 'Transfer Created')
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
        expect(project.awards.last.transfer_type).to eq(project.transfer_types.find_by(name: 'earned'))
      end
    end

    context 'with a lockup token' do
      let(:project) { create(:project, token: create(:lockup_token)) }

      it 'creates a transfer' do
        expect { create_transfer_lockup }.to change { project.awards.count }.by(1)

        expect(project.awards.last.account).to eq(transfer.account)
        expect(project.awards.last.recepient_wallet).to eq(transfer.recepient_wallet)
        expect(project.awards.last.amount).to eq(100)
        expect(project.awards.last.transfer_type).to eq(project.transfer_types.find_by(name: 'earned'))
      end
    end

    context 'without a token' do
      let(:project) { create(:project, token: nil) }

      it 'creates a transfer' do
        expect { create_transfer }.to change { project.awards.count }.by(1)

        expect(project.awards.last.account).to eq(transfer.account)
        expect(project.awards.last.recepient_wallet).to eq(transfer.recepient_wallet)
        expect(project.awards.last.amount).to eq(100)
        expect(project.awards.last.transfer_type).to eq(project.transfer_types.find_by(name: 'earned'))
      end
    end
  end

  context 'when editing a transfer' do
    let(:open_dropdown) do
      first('.transfers-table__transfer__settings a.dropdown').click
      first('.transfers-table__transfer__settings .dropdown-menu')
    end

    let(:open_form) do
      open_dropdown
      first('.transfers-table__transfer__settings .dropdown-menu a.edit-transfer').click
      find('.create-transfer-form-skeleton')
      find('.create-transfer-form')
    end

    let(:edit_transfer) do
      open_form

      fill_in 'Amount', with: '200'
      click_button 'Save'

      find('div', text: 'Transfer Updated')
    end

    context 'and not logged in as an admin' do
      before do
        login create(:account)
        visit project_dashboard_transfers_path(project)
      end

      it { is_expected.not_to have_css('.transfers-table__transfer__settings a.dropdown') }
    end

    context 'and transfer is paid' do
      before do
        open_dropdown
      end

      it { is_expected.not_to have_css('.transfers-table__transfer__settings .dropdown-menu a.edit-transfer') }
    end

    context 'and transfer is accepted' do
      let!(:transfer) { create(:transfer) }

      context 'with an non-lockup token' do
        it 'updates transfer' do
          expect { edit_transfer }.not_to(change { project.awards.count })

          expect(project.awards.last.amount).to eq(200)
        end
      end

      context 'with a lockup token' do
        let(:project) { create(:project, token: create(:lockup_token)) }
        let!(:transfer) { create(:transfer, lockup_schedule_id: 0, commencement_date: Time.current, award_type: create(:award_type, project: project)) }

        it 'updates transfer' do
          expect { edit_transfer }.not_to(change { project.awards.count })

          expect(project.awards.last.amount).to eq(200)
        end
      end
    end
  end
end

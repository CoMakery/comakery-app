require 'rails_helper'

describe 'Create Transfer', js: true, skip: true do
  let(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }
  let(:project) { transfer.project }

  let(:open_dropdown) do
    find('.create-transfer').click
    find('.create-transfer-dropdown')
  end

  let(:open_form) do
    open_dropdown

    find('.create-transfer-dropdown .dropdown-item', text: 'Burn').click
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
  end

  before do
    login project.account
    visit project_dashboard_transfers_path(project)
  end

  scenario 'creates Burn transfer' do
    expect { create_transfer }.to change { project.awards.count }.by(1)

    expect(project.awards.last.transfer_type.name).to eq('burn')
  end
end

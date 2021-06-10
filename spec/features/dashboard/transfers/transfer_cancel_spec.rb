require 'rails_helper'

describe 'cancelling transfer', :js do
  let(:transfer) { create(:transfer) }
  let(:project) { transfer.project }

  before do
    login project.account
    visit project_dashboard_transfers_path(project)
    first('.transfers-table__transfer__settings a.dropdown').click
    first('.transfers-table__transfer__settings .dropdown-menu')
  end

  let(:transfer_cancel_link_selector) do
    "a[data-method='delete'][href='#{project_award_type_award_path(project, transfer.award_type, transfer)}']"
  end

  subject { page }

  context 'when transfer is accepted' do
    it { is_expected.to have_selector transfer_cancel_link_selector }
  end

  context 'when transfer is paid' do
    let(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }

    it { is_expected.not_to have_selector transfer_cancel_link_selector }
  end
end

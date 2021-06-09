require 'rails_helper'

describe 'Transfer type dropdown', js: true do
  let(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }
  let(:project) { transfer.project }

  before do
    project.update!(visibility: :public_listed)
    login project.account
    visit project_dashboard_transfers_path(project)
  end

  context 'when open dropdown' do
    let(:transfer_types) { project.transfer_types.pluck(:name).map(&:capitalize) }

    let(:open_dropdown) do
      find('.create-transfer').click
      find('.create-transfer-dropdown')
    end

    it 'shows list of project transfer types' do
      transfer_types.all? { |type| expect(open_dropdown.text).to have_content(type) }
    end

    context 'and chose specific transfer type' do
      let(:open_form) do
        open_dropdown

        find('.create-transfer-dropdown .dropdown-item', text: 'Burn').click
        find('.create-transfer-form')
      end

      it 'shows transfer form with the selected transfer type' do
        expect(open_form.text).to have_content('Burn')
      end
    end
  end
end

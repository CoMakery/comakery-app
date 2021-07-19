require 'rails_helper'

describe 'transfers_index_page', js: true do
  let(:owner) { create :account }
  let!(:project_award_type) { (create :award_type, project: project) }

  context 'when project has an assigned hot walled' do
    let(:project) { create :project, token: nil, account: owner, transfer_batch_size: 99 }
    let!(:wallet) { create(:wallet, source: :hot_wallet, project_id: project.id) }

    it 'show a modal with batch size form and update it' do
      login(owner)
      visit project_dashboard_transfers_path(project)

      expect(page).to have_content('Batch size')
      expect(page).to have_field('project_transfer_batch_size_input', with: '99')

      find('.project-transfer-batch-size').click

      within('#project_transfer_batch_size_modal_form') do
        fill_in('project[transfer_batch_size]', with: '105')
        click_button('Save')
      end

      expect(page).to have_field('project_transfer_batch_size_input', with: '105', wait: 90)
    end
  end
end

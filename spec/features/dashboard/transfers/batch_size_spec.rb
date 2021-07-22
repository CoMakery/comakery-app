require 'rails_helper'

RSpec.feature 'Batch size', type: :feature, js: true do
  let!(:project) { FactoryBot.create(:project, token: nil, transfer_batch_size: 99) }
  let!(:project_award_type) { FactoryBot.create(:award_type, project: project) }
  let!(:wallet) { FactoryBot.create(:wallet, source: :hot_wallet, project_id: project.id) }

  scenario 'user updates batch size value' do
    login(project.account)

    visit project_dashboard_transfers_path(project)

    expect(page).to have_content('Batch size')

    expect(page).to have_field('project_transfer_batch_size_input', with: '99')

    find('.project-transfer-batch-size').click

    within('#project_transfer_batch_size_modal_form') do
      fill_in('project[transfer_batch_size]', with: '105')

      click_button('Save')
    end

    expect(page).to have_field('project_transfer_batch_size_input', with: '105')
  end
end

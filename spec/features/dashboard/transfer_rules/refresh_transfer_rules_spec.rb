require 'rails_helper'

describe 'refresh_transfer_rules' do
  let(:owner) { create :account }
  let(:token) { create(:comakery_dummy_token) }
  let!(:project) { create :project, token: token, account: owner }
  let!(:project_award_type) { (create :award_type, project: project) }

  example 'Returns correct number of transfers after applying filter' do
    login(owner)
    visit project_dashboard_transfer_rules_path(project)

    expect(page).to have_content '1 Group'
    expect(page).to have_content '0 Rules'

    VCR.use_cassette("infura/#{token._blockchain}/#{token.contract_address}/filtered_logs") do
      click_button 'refresh transfer rules'
    end

    expect(page).to have_content '10 Groups'
    expect(page).to have_content '35 Rules'
    expect(page).to have_button 'refresh transfer rules', disabled: true
  end
end

require 'rails_helper'

feature 'pages' do
  let!(:account) { create :account, contributor_form: true }
  let!(:token) { create :token }
  let!(:mission) { create :mission, token_id: token.id, image: File.open(Rails.root.join('spec', 'fixtures', 'helmet_cat.png'), 'rb') }
  let!(:project) { create :project, mission_id: mission.id }

  scenario '#featured' do
    stub_airtable
    account.interests.create(project_id: project.id, protocol: 'Holo')
    login account
    visit root_path
    expect(page).to have_content 'Request Sent'
  end
end

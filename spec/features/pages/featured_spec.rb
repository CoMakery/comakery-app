require 'rails_helper'

feature 'pages' do
  let!(:account) { create :account, contributor_form: true }
  let!(:token) { create :token }
  let!(:mission1) { create :mission, name: 'test1', token_id: token.id, image: File.open(Rails.root.join('spec', 'fixtures', 'helmet_cat.png'), 'rb') }
  let!(:mission2) { create :mission, name: 'test2', token_id: token.id, image: File.open(Rails.root.join('spec', 'fixtures', 'helmet_cat.png'), 'rb') }
  let!(:mission3) { create :mission, name: 'test3', token_id: token.id, image: File.open(Rails.root.join('spec', 'fixtures', 'helmet_cat.png'), 'rb') }
  let!(:mission4) { create :mission, name: 'test4', token_id: token.id, image: File.open(Rails.root.join('spec', 'fixtures', 'helmet_cat.png'), 'rb') }
  let!(:mission5) { create :mission, name: 'test5', token_id: token.id, image: File.open(Rails.root.join('spec', 'fixtures', 'helmet_cat.png'), 'rb') }
  let!(:project) { create :project, title: 'default project 8344', mission_id: mission1.id, visibility: 'public_listed' }
  let!(:project_featured) { create :project, title: 'featured project 9934', mission_id: mission1.id, visibility: 'public_listed', status: 0 }

  scenario '#featured' do
    stub_airtable
    account.interests.create(project_id: project_featured.id, protocol: 'Holo')
    login account

    visit root_path
    expect(page).not_to have_content 'default project 8344'
    expect(page).to have_content 'featured project 9934'
    expect(page).to have_content 'Following'
    expect(page).to have_content 'test1'
    expect(page).to have_content 'test2'
    expect(page).to have_content 'test3'
    expect(page).to have_content 'test4'
    expect(page).to have_content 'test5'
  end
end

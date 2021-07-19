require 'rails_helper'

describe 'Admin Tabs' do
  let!(:account) { create :account }
  let!(:admin_account) { create :account, comakery_admin: true }
  let!(:whitelabel_mission) { create :whitelabel_mission, whitelabel_domain: 'www.example.com' }

  scenario 'hide tabs when current_account has not comakery_admin flag' do
    login(account)
    visit root_path
    expect(page).not_to have_link('All Accounts')
    expect(page).not_to have_link('Missions Admin')
    expect(page).not_to have_link('Tokens Admin')
  end

  scenario 'show tabs when current_account has comakery_admin flag' do
    login(admin_account)
    visit root_path
    expect(page).to have_link('All Accounts')
    expect(page).to have_link('Missions Admin')
    expect(page).to have_link('Tokens Admin')
  end

  scenario 'hide tasks when whitelabel mission awards are hidden' do
    login(account)

    visit root_path

    expect(page).not_to have_link('My Tasks')
  end

  scenario 'show tasks when whitelabel mission awards are visible' do
    whitelabel_mission.update(project_awards_visible: true)

    login(account)

    visit root_path

    expect(page).to have_link('My Tasks')
  end
end

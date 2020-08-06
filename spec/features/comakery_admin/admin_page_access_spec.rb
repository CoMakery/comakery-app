require 'rails_helper'

describe 'admin_page_access' do
  let!(:account) { create :account }
  let!(:admin_account) { create :account, comakery_admin: true }

  scenario 'allow comakery admins to navigate to the missions admin page clicking menu header button' do
    login(admin_account)
    visit root_path
    click_link 'Missions Admin'
    expect(current_path).to have_content('missions')
  end

  scenario 'allow comakery admins to navigate to the tokens admin page clicking menu header button' do
    login(admin_account)
    visit root_path
    click_link 'Tokens Admin'
    expect(current_path).to have_content('tokens')
  end

  scenario 'allow comakery admins to navigate manually to the missions admin page' do
    login(admin_account)
    visit '/missions'
    expect(current_path).to have_content('missions')
  end

  scenario 'do not allow non-comakery admins to navigate manually to the missions admin page' do
    login(account)
    visit '/missions'
    expect(current_path).to have_no_content('missions')
  end

  scenario 'allow comakery admins to navigate manually to the token admin page' do
    login(admin_account)
    visit '/tokens'
    expect(current_path).to have_content('tokens')
  end

  scenario 'do not allow non-comakery admins to navigate manually to the token admin page' do
    login(account)
    visit '/tokens'
    expect(current_path).to have_no_content('tokens')
  end
end

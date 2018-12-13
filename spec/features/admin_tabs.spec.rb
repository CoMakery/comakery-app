require 'rails_helper'

describe 'admin_tabs' do
  let!(:account) { create :account }
  let!(:admin_account) { create :account, comakery_admin: true }

  scenario 'hide tabs when current_account has not comakery_admin flag' do
    login(account)
    visit root_path
    expect(page).not_to have_link('MISSIONS')
    expect(page).not_to have_link('TOKENS')
  end

  scenario 'show tabs when current_account has comakery_admin flag' do
    login(admin_account)
    visit root_path
    expect(page).to have_link('MISSIONS')
    expect(page).to have_link('TOKENS')
  end
end

require 'rails_helper'

describe 'tokens features', js: true do
  let!(:admin_account) { create :account, comakery_admin: true }

  before do
    login(admin_account)
  end

  scenario 'admin creates a token' do
    visit root_path
    first('.menu').click_link 'TOKENS'
  end

  scenario 'admin views list of tokens' do
  end

  scenario 'admin views token details' do
  end

  scenario 'admin edits token details' do
  end
end

require 'rails_helper'

feature 'pages' do
  let!(:account) { create :account, contributor_form: true }

  scenario '#featured' do
    stub_airtable
    account.interests.create(project: 'Market Research', protocol: 'Holo')
    login account
    visit root_path
    expect(page).to have_content 'INTEREST, NOTED!'
  end
end

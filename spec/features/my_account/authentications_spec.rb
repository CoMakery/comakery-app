require 'rails_helper'
require 'refile/file_double'
feature 'my account' do
  let!(:team) { create :team }
  let!(:project) { create(:sb_project, ethereum_enabled: true) }
  let!(:account) { create :account, nickname: 'jason' }
  let!(:auth) { create(:sb_authentication, account: account) }
  let!(:issuer) { create(:sb_authentication) }
  let!(:award_type) { create(:award_type, project: project, amount: 1337) }
  let!(:award1) do
    create(:award, award_type: award_type, account: auth.account,
                   issuer: issuer.account, created_at: Date.new(2016, 3, 25))
  end
  let!(:award2) do
    create(:award, award_type: award_type, account: auth.account,
                   issuer: issuer.account, created_at: Date.new(2016, 3, 25))
  end

  before do
    team.build_authentication_team auth
  end

  scenario 'viewing' do
    visit root_path
    expect(page).not_to have_link 'ACCOUNT'
    login(auth.account)

    visit account_path(history: true)

    expect(page).to have_content 'Swarmbot'
    expect(page).to have_content '1,337'
    expect(page).to have_content 'Mar 25, 2016'
    expect(page).to have_content auth.account.decorate.name
  end

  scenario 'editing, and adding an ethereum address' do
    login(auth.account)
    visit root_path
    first('.menu').click_link 'ACCOUNT'

    within('.ethereum_wallet') do
      find('#toggle-edit').click
      click_link 'Cancel'

      find('#toggle-edit').click
      fill_in 'Ethereum Address', with: 'too short and with spaces'
      click_on 'Save'
    end

    expect(page).to have_content "should start with '0x', followed by a 40 character ethereum address"

    within('.ethereum_wallet') do
      fill_in 'Ethereum Address', with: "0x#{'a' * 40}"
      click_on 'Save'
    end

    expect(page).to have_content 'Your account details have been updated.'
    expect(page.find('#ethereum_wallet').value).to eq "0x#{'a' * 40}"
  end

  scenario 'adding an ethereum address sends ethereum tokens, for awards' do
    login(auth.account)
    visit root_path
    first('.menu').click_link 'ACCOUNT'

    within('.ethereum_wallet') do
      find('#toggle-edit').click
      fill_in 'Ethereum Address', with: "0x#{'a' * 40}"
      click_on 'Save'
    end

    expect(EthereumTokenIssueJob.jobs.length).to eq(0)
  end

  scenario 'show account image' do
    account.image = Refile::FileDouble.new('dummy', 'avatar.png', content_type: 'image/png')
    account.save
    login(account)
    visit root_path
    expect(page).to have_css("img[src*='avatar.png']")
    first('.menu').click_link 'ACCOUNT'
    expect(page).to have_css("img[src*='avatar.png']")
  end

  scenario 'show account name' do
    login(account)
    visit root_path
    expect(page).to have_content('jason')
  end
end

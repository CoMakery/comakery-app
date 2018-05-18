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
    expect(page).not_to have_link 'Account'
    login(auth.account)

    visit root_path
    first('.menu').click_link 'Account'

    expect(page).to have_content 'Swarmbot'
    expect(page).to have_content '1,337'
    expect(page).to have_content 'Mar 25, 2016'
    expect(page).to have_content 'Contribution'
    expect(page).to have_content 'Great work'
    expect(page).to have_content auth.account.decorate.name
  end

  scenario 'editing, and adding an ethereum address' do
    login(auth.account)
    visit root_path
    first('.menu').click_link 'Account'

    within('.ethereum_wallet') do
      click_link 'Edit'
      click_link 'Cancel'

      click_link 'Edit'
      fill_in 'Ethereum Address', with: 'too short and with spaces'
      click_on 'Save'
    end

    expect(page).to have_content "Ethereum wallet should start with '0x',
      followed by a 40 character ethereum address"

    within('.ethereum_wallet') do
      fill_in 'Ethereum Address', with: "0x#{'a' * 40}"
      click_on 'Save'
    end

    expect(page).to have_content 'Your account details have been updated.'
    expect(page).to have_content "0x#{'a' * 40}"
  end

  scenario 'adding an ethereum address sends ethereum tokens, for awards' do
    login(auth.account)
    visit root_path
    first('.menu').click_link 'Account'

    within('.ethereum_wallet') do
      click_link 'Edit'
      fill_in 'Ethereum Address', with: "0x#{'a' * 40}"
      click_on 'Save'
    end

    expect(EthereumTokenIssueJob.jobs.map { |job| job['args'] }.flatten).to \
      match_array([award2.id, award1.id])
  end

  scenario 'show account image' do
    account.image = Refile::FileDouble.new('dummy', 'avatar.png', content_type: 'image/png')
    account.save
    login(account)
    visit root_path
    expect(page).to have_css("img[src*='avatar.png']")
  end

  scenario 'show account name' do
    login(account)
    visit root_path
    expect(page).to have_content('jason')
  end
end

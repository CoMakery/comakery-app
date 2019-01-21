require 'rails_helper'
require 'refile/file_double'

feature 'my account', js: true do
  let!(:team) { create :team }
  let!(:project) { create(:sb_project, ethereum_enabled: true) }
  let!(:account) { create :account, nickname: 'jason' }
  let(:account_nickname) { account.decorate.name }

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
    expect(page).not_to have_link account_nickname
    login(auth.account)

    # visit account_path(history: true)
    # Now we dont have refresh -> instead we should click radio button on React component
    visit account_path
    choose 'History'

    expect(page).to have_content 'Swarmbot'
    expect(page).to have_content '1337.0'
    expect(page).to have_content 'Mar 25, 2016'
    expect(page).to have_content account_nickname
  end

  scenario 'editing, and adding an ethereum address' do
    login(auth.account)
    visit root_path
    first('.header--nav--links').click_link 'My Account'

    within('.view-ethereum-wallet') do
      first(:link).click
    end

    fill_in 'ethereumWallet', with: 'too short and with spaces'
    find('input[type=submit]').click

    expect(page).to have_content "should start with '0x', followed by a 40 character ethereum address"
  end

  scenario 'editing, and adding an qtum address' do
    login(auth.account)
    visit root_path
    first('.header--nav--links').click_link 'My Account'

    within('.view-ethereum-wallet') do
      first(:link).click
    end

    fill_in 'qtumWallet', with: 'too short and with spaces'
    find('input[type=submit]').click

    expect(page).to have_content "should start with 'Q', followed by 33 characters"
  end

  scenario 'adding an ethereum address sends ethereum tokens, for awards' do
    login(auth.account)
    visit root_path
    first('.header--nav--links').click_link 'My Account'

    within('.view-ethereum-wallet') do
      first(:link).click
    end

    fill_in 'ethereumWallet', with: "0x#{'a' * 40}"
    fill_in 'qtumWallet', with: "Q#{'a' * 33}"
    fill_in 'cardanoWallet', with: 'Ae2tdPwUPEZ3uaf7wJVf7ces9aPrc6Cjiz5eG3gbbBeY3rBvUjyfKwEaswp'
    fill_in 'bitcoinWallet', with: 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps'
    find('input[type=submit]').click

    expect(page).to have_content 'Your account details have been updated.'
    expect(page.find('.fake-link.copy-source').value).to eq "Q#{'a' * 33}"
    expect(page.find('.fake-link.copy-source2').value).to eq "0x#{'a' * 40}"
    expect(page.find('.fake-link.copy-source3').value).to eq 'Ae2tdPwUPEZ3uaf7wJVf7ces9aPrc6Cjiz5eG3gbbBeY3rBvUjyfKwEaswp'

    expect(EthereumTokenIssueJob.jobs.length).to eq(0)
  end

  scenario 'show account image' do
    account.image = Refile::FileDouble.new('dummy', 'avatar.png', content_type: 'image/png')
    account.save
    login(account)
    visit root_path
    first('.header--nav--links').click_link 'My Account'
    expect(page).to have_css("img[src*='avatar.png']")
  end

  scenario 'show account name' do
    login(account)
    visit root_path
    first('.header--nav--links').click_link 'My Account'
    expect(page).to have_content('jason')
  end
end

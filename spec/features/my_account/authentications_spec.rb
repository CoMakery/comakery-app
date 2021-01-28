require 'rails_helper'

feature 'my account', js: true do
  let!(:team) { create :team }
  let!(:project) { create(:sb_project, ethereum_enabled: true) }
  let!(:account) { create :account, nickname: 'jason' }
  let(:account_nickname) { account.decorate.nick }

  let!(:auth) { create(:sb_authentication, account: account) }
  let!(:issuer) { create(:sb_authentication) }
  let!(:award_type) { create(:award_type, project: project) }
  let!(:award1) do
    create(:award, award_type: award_type, amount: 1337, account: auth.account,
                   issuer: issuer.account, created_at: Date.new(2016, 3, 25))
  end
  let!(:award2) do
    create(:award, award_type: award_type, amount: 1337, account: auth.account,
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
    visit show_account_path
    choose 'History'

    expect(page).to have_content 'Swarmbot'
    expect(page).to have_content '1,337'
    expect(page).to have_content 'Mar 25, 2016'
    expect(page).to have_content account_nickname
  end

  scenario 'show account image' do
    account.image = dummy_image
    account.save
    login(account)
    visit show_account_path

    expect(page).to have_css("img[src*='dummy_image']")
  end

  scenario 'show account name' do
    login(account)
    visit show_account_path

    expect(page).to have_content('jason')
  end
end

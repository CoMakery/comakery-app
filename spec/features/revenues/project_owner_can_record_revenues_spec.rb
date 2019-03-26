require 'rails_helper'

# TODO: Depricated
describe 'when recording revenue', skip: true do
  let!(:team) { create :team }
  let!(:owner) { create(:account, first_name: 'John', last_name: 'Doe') }
  let!(:owner_auth) { create(:authentication, account: owner) }
  let!(:other_account) { create(:account) }
  let!(:other_account_auth) { create(:authentication, account: other_account) }
  let!(:project) { create(:project, visibility: 'public_listed', payment_type: 'revenue_share', require_confidentiality: false, account: owner) }
  let!(:award_type) { create(:award_type, project: project, community_awardable: false, name: 'Code Contribution') }

  before do
    team.build_authentication_team owner_auth
    team.build_authentication_team other_account_auth
    stub_slack_user_list
    stub_slack_channel_list
  end

  it 'revenue page looks sensible when there are no entries recorded yet' do
    login owner
    visit project_revenues_path(project)

    within '.revenues' do
      expect(page).not_to have_css('table')
      expect(page).to have_content('No revenue yet.')
    end
  end

  it 'project owner can record revenues' do
    login owner
    visit project_revenues_path(project)

    fill_in 'Amount', with: 10
    fill_in :revenue_comment, with: 'A comment'
    fill_in :revenue_transaction_reference, with: '0e3e2357e806b6cdb1f70b54c3a3a17b6714ee1f0e68bebb44a74b1efd512098'
    click_on 'Record Revenue'

    within '.revenues' do
      expect(page.all('.transaction-reference')[0]).to have_content('0e3e2357e806b6cdb1f70b54c3a3a17b6714ee1f0e68bebb44a74b1efd512098')
      expect(page.all('.comment')[0]).to have_content('A comment')
      expect(page).to have_content('$10.00')
      expect(page.all('.recorded-by')[0]).to have_content('John Doe')
    end
  end

  it 'parses amounts with both commas and decimal point' do
    login owner
    visit project_revenues_path(project)

    fill_in :revenue_amount, with: '1,234.56'
    click_on 'Record Revenue'

    within '.revenues' do
      expect(page).to have_content('$1,234.56')
    end
  end

  it 'project denomination cannot be changed after first revenue is recorded but other settings can be edited' do
    login owner
    visit project_revenues_path(project)

    fill_in :revenue_amount, with: 1
    click_on 'Record Revenue'

    click_on 'Settings'
    expect(page).to have_css('#project_denomination[disabled]')

    fill_in 'Title', with: 'Mindfulness App'
    fill_in 'Description', with: 'This is a project'
    fill_in "Project Owner's Legal Name", with: 'Mindful Inc'
    check 'Contributions are exclusive'
    check 'Require project and business confidentiality'

    click_on 'Save', class: 'last_submit'
    expect(page).to have_current_path(project_path(project))
    expect(page).not_to have_content('cannot be changed because revenue has been recorded')
    expect(page).not_to have_css('.error')
  end

  it 'revenues appear in reverse chronological order' do
    login owner
    visit project_revenues_path(project)

    [3, 2, 1].each do |amount|
      fill_in :revenue_amount, with: amount
      click_on 'Record Revenue'
    end

    within '.revenues' do
      expect(page.all('.amount')[0]).to have_content('$1.00')
      expect(page.all('.amount')[1]).to have_content('$2.00')
      expect(page.all('.amount')[2]).to have_content('$3.00')
    end
  end

  it 'non-project owner cannot record revenues' do
    login other_account
    visit project_revenues_path(project)

    expect(page).not_to have_css('.new_revenue')
  end

  it 'project members can see a summary of the project state' do
    project.update(royalty_percentage: 10)
    project.revenues.create(amount: 1000, currency: 'USD', recorded_by: project.account)
    project.revenues.create(amount: 270, currency: 'USD', recorded_by: project.account)
    create(:award, award_type: award_type, quantity: 1.01, amount: 1000, issuer: owner, account: owner)

    login owner
    visit project_revenues_path(project)

    within('.reserved-for-contributors') do
      expect(page.find('.royalty-percentage')).to have_content('10%')
      expect(page.find('.total-revenue')).to have_content('$1,270')
      expect(page.find('.total-revenue-shared')).to have_content('$127.00')
    end
  end

  it 'updates the contributors page', js: true do
    project.update(royalty_percentage: 10)
    create(:award, award_type: award_type, quantity: 7, amount: 1000, issuer: owner, account: owner)
    create(:award, award_type: award_type, quantity: 5, amount: 1000, issuer: owner, account: other_account)

    login owner
    visit project_revenues_path(project)

    [3, 2, 1].each do |amount|
      fill_in :revenue_amount, with: amount
      click_on 'Record Revenue'
    end

    visit project_contributors_path(project)
    contributor_holdings = page.all('.holdings-value')
    expect(contributor_holdings.size).to eq(2)
    expect(contributor_holdings[0]).to have_content('$0.35')
    expect(contributor_holdings[1]).to have_content('$0.25')
  end

  it 'shows errors if there were missing fields' do
    login owner
    visit project_revenues_path(project)

    click_on 'Record Revenue'
    expect(page.all('.amount').size).to eq(0)
    within('form.new_revenue') do
      expect(page.find('small.error')).to have_text("can't be blank and is not a number")
    end
  end

  describe 'it displays correct currency precision for' do
    before do
      login owner
    create(:award, award_type: award_type, quantity: 7, amount: 1000, issuer: owner, account: owner)
    end

    it 'usd' do
      project.token.USD!
      visit project_revenues_path(project)

      fill_in :revenue_amount, with: '4,321.12'
      click_on 'Record Revenue'
      expect(page.find('.revenues .amount')).to have_content('$4,321.12')

      within('.reserved-for-contributors') do
        expect(page.find('.total-revenue')).to have_content('$4,321.12')
        expect(page.find('.total-revenue-shared')).to have_content('$254.94')
      end
    end

    it 'btc' do
      project.token.BTC!
      visit project_revenues_path(project)

      fill_in :revenue_amount, with: '4,321.12345678'
      click_on 'Record Revenue'

      within('.reserved-for-contributors') do
        expect(page.find('.total-revenue')).to have_content(/฿4,321.[0-9]{8}/)
        expect(page.find('.total-revenue-shared')).to have_content(/฿254.[0-9]{8}/)
      end
    end

    it 'eth' do
      project.token.ETH!
      visit project_revenues_path(project)

      fill_in :revenue_amount, with: '4,321.123456789012345678'
      click_on 'Record Revenue'
      within('.reserved-for-contributors') do
        expect(page.find('.total-revenue')).to have_content(/^Ξ4,321.[0-9]{18}$/)
        expect(page.find('.total-revenue-shared')).to have_content(/^Ξ254.[0-9]{18}$/)
      end
    end
  end

  it 'no revenues page displayed for project_tokens' do
    project.project_token!

    login owner
    visit project_revenues_path(project)
    expect(page).to have_current_path(root_path)
  end

  it 'no revenues page displayed when 0% royalty percentage' do
    project.update_attributes(royalty_percentage: 0)

    login owner
    visit project_revenues_path(project)
    expect(page).to have_current_path(root_path)
  end

  describe 'non-members' do
    before do
      project.update_attributes(require_confidentiality: false, visibility: 'public_listed')
      visit logout_path
    end

    it "non-members can see revenues if confidentiality isn't required for a public project" do
      visit project_revenues_path(project)
      expect(page).to have_current_path(project_revenues_path(project))
    end

    it "non-members can't see revenues if confidentiality is required for a public project" do
      project.update_attribute(:require_confidentiality, true)

      visit project_path(project)
      expect(page).not_to have_link 'Revenues'

      visit project_revenues_path(project)
      expect(page).to have_current_path(root_path)
    end

    it "non-members can't see revenues if it's a private project" do
      project.member!

      visit project_path(project)
      expect(page).not_to have_link 'Revenues'

      visit project_revenues_path(project)
      expect(page).to have_current_path('/404.html')
    end
  end
end

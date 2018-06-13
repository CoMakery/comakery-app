require 'rails_helper'

describe 'viewing projects, creating and editing', :js do
  let!(:team) { create :team }
  let!(:project) { create(:project, title: 'Cats with Lazers Project', description: 'cats with lazers', account: account, public: false) }
  let!(:public_project) { create(:project, title: 'Public Project', description: 'dogs with donuts', account: account, visibility: 'public_listed') }
  let!(:public_project_award_type) { create(:award_type, project: public_project) }
  let!(:public_project_award) { create(:award, award_type: public_project_award_type, created_at: Date.new(2016, 1, 9)) }
  let!(:account) { create(:account, first_name: 'Glenn', last_name: 'Spanky', email: 'gleenn@example.com') }
  let!(:authentication) { create(:authentication, account: account) }
  let!(:same_team_account) { create(:account, ethereum_wallet: "0x#{'1' * 40}") }
  let!(:same_team_account_authentication) { create(:authentication, account: same_team_account) }
  let!(:other_team_account) { create(:account).tap { |a| create(:authentication, account_id: a.id) } }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team same_team_account_authentication
    Rails.application.config.allow_ethereum = 'citizencodedomain'
    travel_to Date.new(2016, 1, 10)
    stub_slack_user_list
    stub_slack_channel_list

    travel_to(DateTime.parse('Mon, 29 Feb 2016 00:00:00 +0000')) # so we can check for fixed date of award

    allow_any_instance_of(Account).to receive(:send_award_notifications)
    stub_slack_user_list([{ "id": 'U99M9QYFQ', "team_id": 'team id', "name": 'bobjohnson', "profile": { "email": 'bobjohnson@example.com' } }])
    stub_request(:post, 'https://slack.com/api/users.info').to_return(body: {
      ok: true,
      "user": {
        "id": 'U99M9QYFQ',
        "team_id": 'team id',
        "name": 'bobjohnson',
        "profile": {
          email: 'bobjohnson@example.com'
        }
      }
    }.to_json)
  end

  after do
    travel_back
  end

  it 'setup project with Project Tokens' do
    login(account)

    visit projects_path

    click_link 'New Project'
    fill_in 'Title', with: 'Mindfulness App'
    fill_in 'project_maximum_tokens', with: '210000'
    fill_in 'Description', with: 'This is a project'
    fill_in "Project Owner's Legal Name", with: 'Mindful Inc'
    check 'Contributions are exclusive'
    check 'Require project and business confidentiality'

    click_on 'Save', class: 'last_submit'
    expect(page).to have_content 'Project created'

    within '.project-terms' do
      expect(page).to have_content 'Mindful Inc'
      expect(page).to have_content 'Contributions: are exclusive'
      expect(page).to have_content 'Business Confidentiality: is required'
      expect(page).to have_content 'Project Confidentiality: is required'
    end
  end

  describe 'denominations shown' do
    before do
      project.update_attributes(payment_type: 'revenue_share')
      login(account)
    end

    specify do
      project.update(denomination: :USD)
      visit edit_project_path(project)
      expect_denomination_usd
    end

    specify do
      project.update(denomination: :BTC)
      visit edit_project_path(project)
      expect_denomination_btc
    end

    specify do
      project.update(denomination: :ETH)
      visit edit_project_path(project)
      expect_denomination_eth
    end

    it 'are hidden for project tokens' do
      project.update(payment_type: :project_token)
      visit edit_project_path(project)
      expect_denomination_hidden
    end

    describe 'denominations are shown and hidden by selecting the project type', js: true do
      before { visit edit_project_path(project) }

      specify { expect_denomination_usd }

      specify do
        select 'US Dollars ($)', from: 'project_denomination'
        expect_denomination_usd
      end

      specify do
        select 'Bitcoin (฿)', from: 'project_denomination'
        expect_denomination_btc
      end

      specify do
        select 'Ether (Ξ)', from: 'project_denomination'
        expect_denomination_eth
      end
    end

    it 'hides the awards section when project token is selected' do
      project.update_attributes(payment_type: :project_token)
      visit edit_project_path(project)
      expect_denomination_hidden
    end
  end

  it 'locks contribution license terms when the contract is finalized' do
    login(account)

    visit projects_path

    click_link 'New Project'
    page.assert_selector('.fa-lock', count: 0)

    fill_in 'Title', with: 'Mindfulness App'
    fill_in 'project_maximum_tokens', with: '100000'
    fill_in 'Description', with: 'This is a project'
    fill_in "Project Owner's Legal Name", with: 'Mindful Inc'
    check 'Contributions are exclusive'
    check 'Require project and business confidentiality'

    click_on 'Save', class: 'last_submit'
    expect(page).to have_content 'Project created'

    click_on 'Settings'
    contract_term_fields.each do |disabled_field_name|
      expect(page).not_to have_css("##{disabled_field_name}[disabled]")
    end
    page.assert_selector('.fa-lock', count: 0)

    # check 'project_license_finalized'

    click_on 'Save', class: 'last_submit'
    click_on 'Settings'
    # page.assert_selector('.fa-lock', count: 1)
  end

  it 'locks maximum authorized if ethereum is enabled' do
    login(account)

    visit edit_project_path(project)
    expect(page).to have_css('#project_maximum_tokens')
    expect(page).not_to have_css('#project_maximum_tokens[disabled]')

    project.update(ethereum_enabled: true)
    visit edit_project_path(project)
    expect(page).to have_css('#project_maximum_tokens[disabled]')
  end

  def contract_term_fields
    %i[project_maximum_tokens
       project_denomination
       project_exclusive_contributions
       project_legal_project_owner
       project_require_confidentiality
       project_royalty_percentage
       project_maximum_royalties_per_month
       project_license_finalized]
  end

  def expect_denomination_usd
    page.assert_selector('span.denomination', text: '$', minimum: 4)
    page.assert_selector('span.denomination', text: '฿', count: 0)
    page.assert_selector('span.denomination', text: 'Project Tokens', count: 0)
  end

  def expect_denomination_btc
    page.assert_selector('span.denomination', text: '$', count: 0)
    page.assert_selector('span.denomination', text: '฿', minimum: 4)
    page.assert_selector('span.denomination', text: 'Ξ', count: 0)
  end

  def expect_denomination_eth
    page.assert_selector('span.denomination', text: '$', count: 0)
    page.assert_selector('span.denomination', text: '฿', count: 0)
    page.assert_selector('span.denomination', text: 'Ξ', minimum: 1)
  end

  def expect_denomination_hidden
    page.assert_selector('span.denomination', text: '$', count: 0)
    page.assert_selector('span.denomination', text: '฿', count: 0)
    page.assert_selector('span.denomination', text: 'Ξ', count: 0)
  end

  def expect_royalty_terms
    assert_royalty_terms(true)
  end

  def expect_no_royalty_terms
    assert_royalty_terms(false)
  end

  def assert_royalty_terms(bool)
    to_or_not = bool ? 'to' : 'to_not'
    expect(page).send(to_or_not, have_content('Royalty Terms'))
    expect(page).send(to_or_not, have_content('Percentage of Revenue '))
  end
end

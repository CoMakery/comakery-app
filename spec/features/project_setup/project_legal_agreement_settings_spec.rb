require "rails_helper"

describe "viewing projects, creating and editing", :js do
  let!(:project) { create(:project, title: "Cats with Lazers Project", description: "cats with lazers", owner_account: account, slack_team_id: "citizencode", public: false) }
  let!(:public_project) { create(:project, title: "Public Project", description: "dogs with donuts", owner_account: account, slack_team_id: "citizencode", public: true) }
  let!(:public_project_award_type) { create(:award_type, project: public_project) }
  let!(:public_project_award) { create(:award, award_type: public_project_award_type, created_at: Date.new(2016, 1, 9)) }
  let!(:account) { create(:account, email: "gleenn@example.com").tap { |a| create(:authentication, account_id: a.id, slack_team_id: "citizencode", slack_team_domain: "citizencodedomain", slack_team_name: "Citizen Code", slack_team_image_34_url: "https://slack.example.com/awesome-team-image-34-px.jpg", slack_team_image_132_url: "https://slack.example.com/awesome-team-image-132-px.jpg", slack_user_name: 'gleenn', slack_first_name: "Glenn", slack_last_name: "Spanky") } }
  let!(:same_team_account) { create(:account, ethereum_wallet: "0x#{'1'*40}") }
  let!(:same_team_account_authentication) { create(:authentication, account: same_team_account, slack_team_id: "citizencode", slack_team_name: "Citizen Code") }
  let!(:other_team_account) { create(:account).tap { |a| create(:authentication, account_id: a.id, slack_team_id: "comakery", slack_team_name: "CoMakery") } }
  let(:bobjohnsons_auth) { Authentication.find_by(slack_user_name: "bobjohnson") }

  before do
    Rails.application.config.allow_ethereum = 'citizencodedomain'
    travel_to Date.new(2016, 1, 10)
    stub_slack_user_list
    stub_slack_channel_list

    travel_to(DateTime.parse("Mon, 29 Feb 2016 00:00:00 +0000")) # so we can check for fixed date of award

    allow_any_instance_of(Account).to receive(:send_award_notifications)
    stub_slack_user_list([{"id": "U99M9QYFQ", "team_id": "team id", "name": "bobjohnson", "profile": {"email": "bobjohnson@example.com"}}])
    stub_request(:post, "https://slack.com/api/users.info").to_return(body: {
        ok: true,
        "user": {
            "id": "U99M9QYFQ",
            "team_id": "team id",
            "name": "bobjohnson",
            "profile": {
                email: "bobjohnson@example.com"
            }
        }
    }.to_json)
  end

  after do
    travel_back
  end

  it "setup revenue sharing project with USD" do
    login(account)

    visit projects_path

    click_link "New Project"
    fill_in "Title", with: "Mindfulness App"
    select "Revenue Shares", from: "project_payment_type"
    fill_in "project_maximum_coins", with: "100000"
    fill_in "Description", with: "This is a project"
    select "a-channel-name", from: "Slack Channel"
    fill_in "Project Owner's Legal Name", with: "Mindful Inc"
    fill_in "project_royalty_percentage", with: "7.99999"
    fill_in "project_maximum_royalties_per_month", with: "25000"
    fill_in "project_revenue_stream", with: "All revenues from xyz."
    check "Contributions are exclusive"
    check "Require project and business confidentiality"

    click_on "Save"
    expect(page).to have_content "Project created"
    expect(page).to have_content "My Balance $0.00 of $0.00"
    within ".project-terms" do
      expect(page).to have_content "Mindful Inc"
      expect(page).to have_content "7.99999%"
      expect(page).to have_content "Maximum Revenue Shares Awarded Per Month: 25,000"
      expect(page).to have_content "Maximum Revenue Shares: 100,000"
      expect(page).to have_content "Contributions: are exclusive"
      expect(page).to have_content "Business Confidentiality: is required"
      expect(page).to have_content "All revenues from xyz."
    end
    within("#award-send") { expect(page).to have_content /award revenue shares/i }

    within(".project-nav") { click_on "Contribution License" }

    expect(page).to have_content "Mindful Inc"
    expect(page).to have_content "7.99999%"
    expect(page).to have_content "Maximum Revenue Shares Awarded Per Month: 25,000"
    expect(page).to have_content "Maximum Revenue Shares: 100,000"
    expect(page).to have_content "Contributions: are exclusive"
    expect(page).to have_content "Business Confidentiality: is required"
    expect(page).to have_content "All revenues from xyz."
  end

  it "setup project with Project Coins" do
    login(account)

    visit projects_path

    click_link "New Project"
    fill_in "Title", with: "Mindfulness App"
    fill_in "project_maximum_coins", with: "210000"
    fill_in "Description", with: "This is a project"
    select "a-channel-name", from: "Slack Channel"
    fill_in "Project Owner's Legal Name", with: "Mindful Inc"
    select "Project Coins", from: "project_payment_type"
    check "Contributions are exclusive"
    check "Require project and business confidentiality"

    click_on "Save"
    expect(page).to have_content "Project created"
    expect(page).to have_content "My Project Coins 0 of 0"
    within ".project-terms" do
      expect(page).to have_content "Mindful Inc"
      expect(page).to have_content "Contributions: are exclusive"
      expect(page).to have_content "Business Confidentiality: is required"
      expect(page).to have_content "Project Confidentiality: is required"
    end

    within("#award-send") { expect(page).to have_content /award project coins/i }
    select "@bobjohnson", from: "User"
    choose "Thanks"
    fill_in "Description", with: "Super fantastic fabulous programatic work on teh things, A++"

    click_button "Send"
    click_link "Contributors"

    expect(page.find('.award-row')).to have_content "@bobjohnson 10 10"

    click_link "Awards"
    expect(page.find('.award-type')).to have_content "Project Coin"
    expect(page.find('.award-total-amount')).to have_content "10"

    login(bobjohnsons_auth.account)
    visit account_path
    expect(page.find('.award-type')).to have_content "Project Coin"
    expect(page.find('.award-total-amount')).to have_content "10"
  end

  describe 'denominations shown' do
    before do
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

    it 'are hidden for project coins' do
      project.update(payment_type: :project_coin)
      visit edit_project_path(project)
      expect_denomination_hidden
    end


    describe 'denominations are shown and hidden by selecting the project type', js: true do
      before { visit edit_project_path(project) }

      specify { expect_denomination_usd }

      specify do
        select "US Dollars ($)", from: 'project_denomination'
        expect_denomination_usd
      end

      specify do
        select "Bitcoin (฿)", from: "project_denomination"
        expect_denomination_btc
      end

      specify do
        select "Ether (Ξ)", from: "project_denomination"
        expect_denomination_eth
      end

      it 'hides the awards section when project coin is selected' do
        select "Project Coins", from: 'project_payment_type'
        expect_denomination_hidden
      end
    end
  end

  it 'should lock contribution license terms when the contract is finalized' do
    login(account)

    visit projects_path

    click_link "New Project"
    page.assert_selector('.fa-lock', count: 0)

    fill_in "Title", with: "Mindfulness App"
    fill_in "project_maximum_coins", with: "100000"
    fill_in "Description", with: "This is a project"
    select "a-channel-name", from: "Slack Channel"
    fill_in "Project Owner's Legal Name", with: "Mindful Inc"
    fill_in "project_royalty_percentage", with: "7.99999"
    fill_in "project_maximum_royalties_per_month", with: "25000"
    check "Contributions are exclusive"
    check "Require project and business confidentiality"

    click_on "Save"
    expect(page).to have_content "Project created"

    click_on "Settings"
    contract_term_fields.each do |disabled_field_name|
      expect(page).to_not have_css("##{disabled_field_name}[disabled]")
    end
    page.assert_selector('.fa-lock', count: 0)
    check 'project_license_finalized'


    click_on "Save"
    click_on "Settings"
    contract_term_fields.each do |disabled_field_name|
      expect(page).to have_css("##{disabled_field_name}[disabled]")
    end
    page.assert_selector('.fa-lock', count: 1)
  end

  it "should lock maximum authorized if ethereum is enabled" do
    login(account)

    visit edit_project_path(project)
    expect(page).to have_css("#project_maximum_coins")
    expect(page).to_not have_css("#project_maximum_coins[disabled]")

    project.update(ethereum_enabled: true)
    visit edit_project_path(project)
    expect(page).to have_css("#project_maximum_coins[disabled]")
  end

  def contract_term_fields
    [:project_maximum_coins,
     :project_denomination,
     :project_exclusive_contributions,
     :project_legal_project_owner,
     :project_require_confidentiality,
     :project_royalty_percentage,
     :project_maximum_royalties_per_month,
     :project_license_finalized]
  end

  def expect_denomination_usd
    page.assert_selector('span.denomination', text: "$", minimum: 4)
    page.assert_selector('span.denomination', text: "฿", count: 0)
    page.assert_selector('span.denomination', text: "Project Coins", count: 0)
  end

  def expect_denomination_btc
    page.assert_selector('span.denomination', text: "$", count: 0)
    page.assert_selector('span.denomination', text: "฿", minimum: 4)
    page.assert_selector('span.denomination', text: "Ξ", count: 0)
  end

  def expect_denomination_eth
    page.assert_selector('span.denomination', text: "$", count: 0)
    page.assert_selector('span.denomination', text: "฿", count: 0)
    page.assert_selector('span.denomination', text: "Ξ", minimum: 1)
  end

  def expect_denomination_hidden
    page.assert_selector('span.denomination', text: "$", count: 0)
    page.assert_selector('span.denomination', text: "฿", count: 0)
    page.assert_selector('span.denomination', text: "Ξ", count: 0)
  end

  def expect_royalty_terms
    assert_royalty_terms(true)
  end

  def expect_no_royalty_terms
    assert_royalty_terms(false)
  end

  def assert_royalty_terms(bool)
    to_or_not = bool ? 'to' : 'to_not'
    expect(page).send(to_or_not, have_content("Royalty Terms"))
    expect(page).send(to_or_not, have_content("Percentage of Revenue "))
  end
end

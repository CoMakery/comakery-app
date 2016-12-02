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

    travel_to(DateTime.parse("Mon, 29 Feb 2016 00:00:00 +0000"))  # so we can check for fixed date of award

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

  it "setup royalties project with USD" do
    login(account)

    visit projects_path

    click_link "New Project"
    fill_in "Title", with: "Mindfulness App"
    select "Royalties paid in US Dollars ($)", from: "Award Payment Type"
    fill_in "Maximum Awards", with: "100000"
    fill_in "Description", with: "This is a project"
    select "a-channel-name", from: "Slack Channel"
    fill_in "Project Owner's Legal Name", with: "Mindful Inc"
    fill_in "Percentage of Revenue reserved", with: "7.99999"
    fill_in "Maximum Royalties Awarded Per Quarter", with: "25000"
    fill_in "Minimum Revenue Collected ", with: "150"
    fill_in "Contributor Minimum Payment", with: "26"
    check "Contributions are exclusive"
    check "Require project and business confidentiality"

    click_on "Save"
    expect(page).to have_content "Project created"
    expect(page).to have_content "$0 mine"
    expect(page).to have_content "$0 awarded"
    within ".project-terms" do
      expect(page).to have_css('.royalty-terms')
      expect(page).to have_content "Mindful Inc"
      expect(page).to have_content "7.99999%"
      expect(page).to have_content "$100,000 maximum royalty"
      expect(page).to have_content "$25,000"
      expect(page).to have_content "$150 minimum revenue"
      expect(page).to have_content "$26 minimum payment"
      expect(page).to have_content "Contributions are exclusive"
      expect(page).to have_content "Confidentiality is required"
    end
    within("#award-send") { expect(page).to have_content /award royalties/i }

    select "@bobjohnson", from: "User"
    choose "Small"
    fill_in "Description", with: "Super fantastic fabulous programatic work on teh things, A++"

    click_button "Send"
    within('.award-rows') { expect(page).to have_content "@bobjohnson $100 $0 $100" }

    click_link "History"
    within(".header-row") { expect(page).to have_content /Royalties Earned/i }
    expect(page).to have_content "$100"

    login(bobjohnsons_auth.account)
    visit account_path
    within(".header-row") { expect(page).to have_content /Royalties Earned/i }
    expect(page).to have_content "$100"
  end

  it "setup royalties project with BTC" do
    login(account)

    visit projects_path

    click_link "New Project"
    fill_in "Title", with: "Mindfulness App"
    select "Royalties paid in Bitcoin (฿)", from: "Award Payment Type"
    fill_in "Maximum Awards", with: "200000"
    fill_in "Description", with: "This is a project"
    select "a-channel-name", from: "Slack Channel"
    fill_in "Project Owner's Legal Name", with: "Mindful Inc"
    fill_in "Percentage of Revenue reserved", with: "8"
    fill_in "Maximum Royalties Awarded Per Quarter", with: "27000"
    fill_in "Minimum Revenue Collected ", with: "170"
    fill_in "Contributor Minimum Payment", with: "27"
    check "Contributions are exclusive"
    check "Require project and business confidentiality"

    click_on "Save"
    expect(page).to have_content "Project created"
    expect(page).to have_content "฿0 mine"
    expect(page).to have_content "฿0 awarded"
    within ".project-terms" do
      expect(page).to have_css('.royalty-terms')
      expect(page).to have_content "Mindful Inc"
      expect(page).to have_content "8.0%"
      expect(page).to have_content "฿200,000 maximum royalty"
      expect(page).to have_content "฿27,000"
      expect(page).to have_content "฿170 minimum revenue"
      expect(page).to have_content "฿27 minimum payment"
      expect(page).to have_content "Contributions are exclusive"
      expect(page).to have_content "Confidentiality is required"
    end
    within("#award-send") { expect(page).to have_content /award royalties/i }

    select "@bobjohnson", from: "User"
    choose "Small"
    fill_in "Description", with: "Super fantastic fabulous programatic work on teh things, A++"

    click_button "Send"
    within('.award-rows') { expect(page).to have_content "@bobjohnson ฿100 ฿0 ฿100" }

    click_link "History"
    within(".header-row") { expect(page).to have_content /Royalties Earned/i }
    expect(page).to have_content "฿100"

    login(bobjohnsons_auth.account)
    visit account_path
    within(".header-row") { expect(page).to have_content /Royalties Earned/i }
    expect(page).to have_content "฿100"
  end

  it "setup project with Project Coins" do
    login(account)

    visit projects_path

    click_link "New Project"
    fill_in "Title", with: "Mindfulness App"
    select "Project Coin direct payment", from: "Award Payment Type"
    fill_in "Maximum Awards", with: "210000"
    fill_in "Description", with: "This is a project"
    select "a-channel-name", from: "Slack Channel"
    fill_in "Project Owner's Legal Name", with: "Mindful Inc"
    check "Contributions are exclusive"
    check "Require project and business confidentiality"

    click_on "Save"
    expect(page).to have_content "Project created"
    expect(page).to have_content "0 awarded"
    expect(page).to have_content "0 mine"
    within ".project-terms" do
      expect(page).to have_content "Mindful Inc"
      expect(page).to have_content "Contributions are exclusive"
      expect(page).to have_content "Confidentiality is required"
    end

    within ".project-terms" do
      expect(page).to_not have_css('.royalty-terms')
      expect(page).to_not have_content "7%"
      expect(page).to_not have_content "maximum royalty awards"
      expect(page).to_not have_content "maximum royalties can be awarded each quarter"
      expect(page).to_not have_content "minimum revenue"
      expect(page).to_not have_content "minimum payment"
    end

    within("#award-send") { expect(page).to have_content /award project coins/i }
    select "@bobjohnson", from: "User"
    choose "Small"
    fill_in "Description", with: "Super fantastic fabulous programatic work on teh things, A++"

    click_button "Send"
    within('.award-rows') { expect(page).to have_content "@bobjohnson 100 0 100" }

    click_link "History"
    within(".header-row") { expect(page).to have_content /Project Coins Earned/i }
    expect(page).to have_content "100"

    login(bobjohnsons_auth.account)
    visit account_path
    within(".header-row") { expect(page).to have_content /Project Coins Earned/i }
    expect(page).to have_content "100"
  end

  describe "royalty legal terms", js: true do
    before do
      login(account)
    end

    it 'are visible for existing usd royalty projects' do
      project.update(payment_type: :royalty_usd)
      visit edit_project_path(project)
      expect_royalty_terms
    end

    it 'are visible for existing bitcoin royalty projects' do
      project.update(payment_type: :royalty_btc)
      visit edit_project_path(project)
      expect_royalty_terms
    end

    it 'are hidden for existing project coin' do
      project.update(payment_type: :project_coin)
      visit edit_project_path(project)
      expect_no_royalty_terms
    end

    it 'are shown and hidden by selecting the project type', js: true  do
      visit edit_project_path(project)
      expect_royalty_terms

      select "Project Coin direct payment", from: "Award Payment Type"
      expect_no_royalty_terms

      select "Royalties paid in US Dollars ($)", from: "Award Payment Type"
      expect_royalty_terms

      select "Royalties paid in Bitcoin (฿)", from: "Award Payment Type"
      expect_royalty_terms
    end
  end

  describe 'denominations should match the project type' do
    before do
      login(account)
    end

    it 'are visible for existing usd royalty projects' do
      project.update(payment_type: :royalty_usd)
      visit edit_project_path(project)
      expect_denomination_usd
    end

    it 'are visible for existing bitcoin royalty projects' do
      project.update(payment_type: :royalty_btc)
      visit edit_project_path(project)
      expect_denomination_btc
    end

    it 'are hidden for existing project coin' do
      project.update(payment_type: :project_coin)
      visit edit_project_path(project)
      expect_denomination_project_coin
    end

    it 'are shown and hidden by selecting the project type', js: true  do
      visit edit_project_path(project)
      expect_denomination_usd

      select "Project Coin direct payment", from: "Award Payment Type"
      expect_denomination_project_coin

      select "Royalties paid in US Dollars ($)", from: "Award Payment Type"
      expect_denomination_usd

      select "Royalties paid in Bitcoin (฿)", from: "Award Payment Type"
      expect_denomination_btc
    end
  end

  def expect_denomination_usd
    page.assert_selector('.denomination', text: "$", minimum: 4)
    page.assert_selector('.denomination', text: "฿", count: 0)
    page.assert_selector('.denomination', text: "Project Coins", count: 0)
  end

  def expect_denomination_btc
    page.assert_selector('.denomination', text: "$", count: 0)
    page.assert_selector('.denomination', text: "฿", minimum: 4)
    page.assert_selector('.denomination', text: "Project Coins", count: 0)
  end

  def expect_denomination_project_coin
    page.assert_selector('.denomination', text: "$", count: 0)
    page.assert_selector('.denomination', text: "฿", count: 0)
    page.assert_selector('.denomination', text: "Project Coins", minimum: 1)
  end

  def expect_royalty_terms
    assert_royalty_terms(true)
  end

  def expect_no_royalty_terms
    assert_royalty_terms(false)
  end

  def assert_royalty_terms(bool)
    to_or_not = bool ? 'to' : 'to_not'
    expect(page).send(to_or_not, have_content("Royalty Legal Terms"))
    expect(page).send(to_or_not, have_content("Percentage of Revenue "))
    expect(page).send(to_or_not, have_content("Maximum Royalties Awarded Per Quarter"))
    expect(page).send(to_or_not, have_content("Minimum Revenue Collected"))
    expect(page).send(to_or_not, have_content("Contributor Minimum Payment"))
  end
end

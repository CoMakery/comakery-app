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

  it "calculator should dynamically display royalty schedule" do
    login(account)

    visit projects_path

    click_link "New Project"
    fill_in "Title", with: "Mindfulness App"
    select "Royalties paid in US Dollars ($)", from: "Award Payment Type"
    fill_in "Maximum Awards", with: "100000"
    fill_in "Description", with: "This is a project"
    select "a-channel-name", from: "Slack Channel"
    fill_in "Project Owner's Legal Name", with: "Mindful Inc"
    fill_in "Maximum Awarded Per Quarter", with: "25000"
    fill_in "Minimum Revenue Collected ", with: "150"
    fill_in "Contributor Minimum Payment", with: "26"
    check "Contributions are exclusive"
    check "Require project and business confidentiality"


    # empty %
    fill_in "Percentage of Revenue reserved", with: ""
    within('.royalty-calc tbody') { expect(page).to have_content('Infinity') }


    # valid #1
    fill_in "Percentage of Revenue reserved", with: "10"
    fill_in "Maximum Awards", with: "12000"
    within('.royalty-calc tbody') do
      expect(page).to have_content('$10')
      expect(page).to have_content('$100')
      expect(page).to have_content('$1000')
      expect(page).to have_content('$10000')

      expect(page).to have_content('1200')
      expect(page).to have_content('120')
      expect(page).to have_content('12')
      expect(page).to have_content('1')
    end

    # valid #2
    fill_in "Percentage of Revenue reserved", with: "5"
    fill_in "Maximum Awards", with: "24000"

    within('.royalty-calc tbody') do
      #revenue
      expect(page).to have_content('$100')
      expect(page).to have_content('$1000')
      expect(page).to have_content('$10000')
      expect(page).to have_content('$100000')

      #monthly payment
      expect(page).to have_content('$5')
      expect(page).to have_content('$50')
      expect(page).to have_content('$500')
      expect(page).to have_content('$5000')

      #months to pay off
      expect(page).to have_content('4800')
      expect(page).to have_content('480')
      expect(page).to have_content('48')
      expect(page).to have_content('5')
    end

    # change the currency
    select "Royalties paid in Bitcoin (฿)", from: "Award Payment Type"

    within('.royalty-calc tbody') do
      expect(page).to have_content('฿100')
      expect(page).to have_content('฿1000')
      expect(page).to have_content('฿10000')
      expect(page).to have_content('฿100000')

      expect(page).to have_content('฿5')
      expect(page).to have_content('฿50')
      expect(page).to have_content('฿500')
      expect(page).to have_content('฿5000')
    end
  end
end
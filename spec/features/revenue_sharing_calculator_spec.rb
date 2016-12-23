require "rails_helper"

describe "viewing projects, creating and editing", :js do
  let!(:project) { create(:project, title: "Cats with Lazers Project", description: "cats with lazers", owner_account: account, slack_team_id: "citizencode", public: false, royalty_percentage: 10) }
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

    login(account)
  end

  after do
    travel_back
  end

  it "calculator should dynamically display royalty schedule" do
    visit edit_project_path(project)

    # empty %
    fill_in "project_royalty_percentage", with: ""
    within('.royalty-calc tbody') { expect(page).to have_content('$1000 $0') }


    # valid #1
    fill_in "project_royalty_percentage", with: "10"
    fill_in "project_maximum_coins", with: "12000"
    within('.royalty-calc tbody') do
      expect(page).to have_content('$1000 $100')
      expect(page).to have_content('$10000 $1000')
      expect(page).to have_content('$100000 $10000')
      expect(page).to have_content('$1000000 $100000')
    end

    # valid #2
    fill_in "project_royalty_percentage", with: "5"
    fill_in "project_maximum_coins", with: "24000"

    within('.royalty-calc tbody') do
      expect(page).to have_content('$1000 $50')
      expect(page).to have_content('$10000 $500')
      expect(page).to have_content('$100000 $5000')
      expect(page).to have_content('$1000000 $50000')
    end

    # change the currency
    select "Bitcoin (฿)", from: "project_denomination"

    within('.royalty-calc tbody') do
      expect(page).to have_content('฿1000 ฿50')
      expect(page).to have_content('฿10000 ฿500')
      expect(page).to have_content('฿100000 ฿5000')
      expect(page).to have_content('฿1000000 ฿50000')
    end

    select "Ether (Ξ)", from: "project_denomination"

    within('.royalty-calc tbody') do
      expect(page).to have_content('Ξ1000 Ξ50')
      expect(page).to have_content('Ξ10000 Ξ500')
      expect(page).to have_content('Ξ100000 Ξ5000')
      expect(page).to have_content('Ξ1000000 Ξ50000')
    end
  end

  describe 'displays alternate text for project coins' do
    it "when selecting payment type" do
      visit edit_project_path(project)
      expect(page).to have_css('.revenue-sharing-terms')
      expect(page).to_not have_css('.project-coin-terms')
      within('.revenue-sharing-terms .royalty-calc') { expect(page).to have_content(%r{Revenue.+Shared}) }

      select "Project Coins", from: :project_payment_type
      expect(page).to_not have_css('.revenue-sharing-terms')
      expect(page).to have_css('.project-coin-terms')
      within('.project-coin-terms') { expect(page).to have_content("About Project Coins") }

      select "Revenue Shares", from: :project_payment_type
      expect(page).to have_css('.revenue-sharing-terms')
      expect(page).to_not have_css('.project-coin-terms')
    end

    it "when editing an existing project" do
      project.update(payment_type: :project_coin)
      visit edit_project_path(project)
      expect(page).to_not have_css('.revenue-sharing-terms')
      expect(page).to have_css('.project-coin-terms')
    end
  end
end
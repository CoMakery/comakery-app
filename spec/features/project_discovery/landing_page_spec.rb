require "rails_helper"

describe "landing page", :js do
  let!(:account) { create(:account, email: "gleenn@example.com").tap { |a| create(:authentication, account_id: a.id, slack_team_id: "citizencode", slack_team_name: "Citizen Code", slack_team_image_34_url: "https://slack.example.com/awesome-team-image-34-px.jpg", slack_user_name: 'gleenn', slack_first_name: "Glenn", slack_last_name: "Spanky", slack_team_domain: "citizencodedomain") } }
  let!(:swarmbot_owner_account) { create(:account, email: "swarm@example.com").tap { |a| create(:authentication, account_id: a.id, slack_team_id: "swarmbot", slack_team_name: "Citizen Code", slack_team_image_34_url: "https://slack.example.com/swarmbot-team-image-34-px.jpg", slack_user_name: 'swarmy', slack_first_name: "Swarm", slack_last_name: "Bot", slack_team_domain: "swarmbot") } }

  it "when logged in shows some projects and the new button" do
    login(account)

    7.times { |i| create(:project, owner_account: swarmbot_owner_account, title: "Public Project #{i}", public: true, slack_team_name: "3D Drones", slack_team_id: "swarmbot") }
    7.times { |i| create(:project, account, title: "Private Project #{i}", public: false, slack_team_id: "citizencode", slack_team_name: "Citizen Code") }

    visit root_path

    within(".top-bar .slack-instance") do
      expect(page).to have_content "Citizen Code"
    end

    within("h2") { expect(page.text).to eq("Citizen Code projects") }
    expect(page.html).to match %r{<img[^>]+src="[^"]+awesome-team-image-\d+-px\.jpg"}
    expect(page).to have_content "New Project"

    expect(page.all(".project").size).to eq(12)
    expect(page).to have_content "Public Project"
    expect(page).to have_content "3D Drones"

    click_link "Browse All"

    within("h2") { expect(page.text).to eq("Projects") }
    expect(page.html).to match %r{<img[^>]+src="[^"]+awesome-team-image-34-px\.jpg"}
    expect(page).to have_content "New Project"

    expect(page.all(".project").size).to eq(14)
    expect(page).to have_content "Public Project"
  end

  it "when logged out shows featured projects first" do
    (1..3).each { |i| create(:project, owner_account: swarmbot_owner_account, title: "Featured Project #{i}", public: true, slack_team_name: "3D Drones", slack_team_id: "swarmbot", featured: i) }
    (1..7).each { |i| create(:project, owner_account: swarmbot_owner_account, title: "Public Project #{i}", public: true, slack_team_name: "3D Drones", slack_team_id: "swarmbot") }


    (1..7).each { |i| create(:project, account, title: "Private Project #{i}", public: false, slack_team_id: "citizencode", slack_team_name: "Citizen Code") }

    visit root_path

    expect(page.all(".project").size).to eq(6)
    within('.main') do
      expect(page).to have_text "Featured Project 1"
      expect(page).to have_text "Featured Project 2"
      expect(page).to have_text "Featured Project 3"
      expect(page).to have_text "Public Project 5"
      expect(page).to have_text "Public Project 6"
      expect(page).to have_text "Public Project 7"

      expect(page).to_not have_text "Public Project 4" # not featured and less active doesn't appear
    end
    click_link "Browse All"

    within("h2") { expect(page.text).to eq("Projects") }

    expect(page.all(".project").size).to eq(10)
    expect(page).to have_content "Featured Project"
    expect(page).to have_content "Public Project"
    expect(page).to_not have_content "Private Project"
  end
end

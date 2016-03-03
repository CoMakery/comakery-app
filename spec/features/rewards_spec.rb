require "rails_helper"

describe "viewing projects, creating and editing", :js, :vcr do
  let!(:project) { create(:project, title: "Project that needs rewards", owner_account: owner_account, slack_team_id: "team id") }

  let!(:small_reward_type) { create(:reward_type, project: project, name: "Small", amount: 1000) }
  let!(:large_reward_type) { create(:reward_type, project: project, name: "Large", amount: 3000) }

  let!(:owner_account) { create(:account, email: "hubert@example.com").tap { |a| create(:authentication, slack_user_name: 'hubert', slack_user_id: 'hubert id', account_id: a.id, slack_team_id: "team id") } }
  let!(:other_account) { create(:account, email: "sherman@example.com").tap { |a| create(:authentication, slack_user_name: 'sherman', slack_user_id: 'sherman id', account_id: a.id, slack_team_id: "team id") } }

  before do
    travel_to(DateTime.parse("Mon, 29 Feb 2016 00:00:00 +0000"))

    expect_any_instance_of(Account).to receive(:send_reward_notifications)
    stub_request(:post, "https://slack.com/api/users.list").to_return(body: {ok: true,
                                                                             members: [{"id": "U99M9QYFQ",
                                                                                        "team_id": "team id",
                                                                                        "name": "bobjohnson",
                                                                                        "profile": {"email": "bobjohnson@example.com"}
                                                                                       }]}.to_json)
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

  describe "rewarding a user which swarmbot doesn't have an account for yet" do
    it "populates the dropdown to select the rewardee and creates the account/auth for the user" do
      login(owner_account)

      visit project_path(project)

      choose "Small"
      expect(page.all("select#reward_slack_user_id option").map(&:text).sort).to eq(["", "bobjohnson", "hubert", "sherman"])
      select "bobjohnson", from: "User"

      click_button "Send"

      expect(page).to have_content "Successfully sent reward to @bobjohnson"

      bobjohnsons_auth = Authentication.find_by(slack_user_name: "bobjohnson")
      expect(bobjohnsons_auth).not_to be_nil

      login(bobjohnsons_auth.account)

      visit project_rewards_path(bobjohnsons_auth.projects.first)

      expect(page).to have_content "bobjohnson"
    end
  end

  it "has a working happy path" do
    login(other_account)

    visit project_path(project)

    expect(page).not_to have_content("Send Reward")

    login(owner_account)

    visit project_path(project)

    click_link "Award History >>"

    expect(page).to have_content("Award History")

    click_link "Back to project"

    expect(page).to have_content("Project that needs rewards")

    click_button "Send"

    expect(page).to have_content "Failed sending reward"

    choose "Small"

    expect(page.all("select#reward_slack_user_id option").map(&:text).sort).to eq(["", "bobjohnson", "hubert", "sherman"])
    select "sherman", from: "User"
    fill_in "Description", with: "Super fantastic fabulous programatic work on teh things, A++"

    click_button "Send"

    expect(page).to have_content "Successfully sent reward to @sherman"
    expect(page).to have_content "Award History"
    expect(page).to have_content "Feb 29"
    expect(page).to have_content "1,000"
    expect(page).to have_content 'Super fantastic fabulous programatic work on teh things, A++'
    expect(page).to have_content "hubert"

    click_link "Back to project"

    expect(page).to have_content("Project that needs rewards")
  end
end

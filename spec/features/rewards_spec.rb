require "rails_helper"

describe "viewing projects, creating and editing", :js, :vcr do
  let!(:project) { create(:project, title: "Project that needs rewards", owner_account: owner_account, slack_team_id: "team id") }

  let!(:small_reward_type) { create(:reward_type, project: project, name: "Small", amount: 1000) }
  let!(:large_reward_type) { create(:reward_type, project: project, name: "Large", amount: 3000) }

  let!(:owner_account) { create(:account, email: "hubert@z.co").tap{|a| create(:authentication, slack_user_name: 'hubert', account_id: a.id, slack_team_id: "team id")} }
  let!(:other_account) { create(:account, email: "sherman@z.co").tap{|a| create(:authentication, slack_user_name: 'sherman', account_id: a.id, slack_team_id: "team id")} }

  before do
    travel_back
    expect_any_instance_of(Account).to receive(:send_reward_notifications)
  end

  specify do
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

    expect(page.all("select#reward_account_id option").map(&:text).sort).to eq(["", "hubert@z.co", "sherman@z.co"])
    select "sherman@z.co", from: "User"
    fill_in "Description", with: "Super fantastic fabulous programatic work on teh things, A++"

    travel_to(DateTime.parse("Mon, 29 Feb 2016 00:00:00 +0000"))

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

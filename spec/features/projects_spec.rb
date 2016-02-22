require "rails_helper"

describe "viewing projects, creating and editing", :js do
  let!(:project) { create(:project, title: "Project 1", owner_account: account, slack_team_id: "citizencode") }
  let!(:project2) { create(:project, title: "Public Project", owner_account: account, slack_team_id: "citizencode", public: true) }
  let!(:account) { create(:account).tap{|a| create(:authentication, account_id: a.id, slack_team_id: "citizencode")} }
  let!(:same_team_account) { create(:account).tap{|a| create(:authentication, account_id: a.id, slack_team_id: "citizencode")} }
  let!(:other_team_account) { create(:account).tap{|a| create(:authentication, account_id: a.id, slack_team_id: "comakery")} }

  specify do
    login(account)

    visit projects_path

    expect(page).to have_content "Project 1"

    within "#project-#{project.to_param}" do
      click_link "View"
    end

    click_link "Back"

    click_link "New Project"

    fill_in "Title", with: "This is a project"
    fill_in "Description", with: "This is a project description which is very informative"
    fill_in "Project Tracker", with: "http://github.com/here/is/my/tracker"
    expect(find_field("Public")).to be_checked

    reward_type_inputs = page.all(".reward-type-row")
    reward_type_inputs[0].all("input")[0].set "This is a small reward type"
    reward_type_inputs[0].all("input")[1].set "1000"
    reward_type_inputs[1].all("input")[0].set "This is a medium reward type"
    reward_type_inputs[1].all("input")[1].set "2000"
    reward_type_inputs[2].all("input")[0].set "This is a large reward type"
    reward_type_inputs[2].all("input")[1].set "3000"

    expect(reward_type_inputs.size).to eq(3)

    click_link "+ add reward type"

    reward_type_inputs = page.all(".reward-type-row")
    expect(reward_type_inputs.size).to eq(4)
    reward_type_inputs[3].all("input")[0].set "This is a super big reward type"
    reward_type_inputs[3].all("input")[1].set "5000"

    click_on "Save"

    expect(page).to have_content "Project created"
    expect(page).to have_content "This is a project"
    expect(page).to have_content "This is a project description which is very informative"
    expect(page).to have_content "Visibility: Public"
    expect(page).to have_link "Project Tasks »"

    reward_type_rows = page.all(".reward-type-row")
    expect(reward_type_rows.size).to eq(4)

    expect(reward_type_rows[0]).to have_content "This is a small reward type"
    expect(reward_type_rows[0]).to have_content "1000"

    expect(reward_type_rows[1]).to have_content "This is a medium reward type"
    expect(reward_type_rows[1]).to have_content "2000"

    expect(reward_type_rows[2]).to have_content "This is a large reward type"
    expect(reward_type_rows[2]).to have_content "3000"

    expect(reward_type_rows[3]).to have_content "This is a super big reward type"
    expect(reward_type_rows[3]).to have_content "5000"

    click_on "Edit"

    expect(page).to have_checked_field("Public")
    fill_in "Title", with: "This is an edited project"
    fill_in "Description", with: "This is an edited project description which is very informative"
    fill_in "Project Tracker", with: "http://github.com/here/is/my/tracker/edit"
    uncheck "Public"

    click_on "Save"

    expect(page).to have_content "Project updated"
    expect(page).to have_content "This is an edited project"
    expect(page).to have_content "This is an edited project description which is very informative"
    expect(page).to have_content "Visibility: Private"

    visit("/projects")

    expect(page).to have_content "This is an edited project"

    login(same_team_account)

    visit("/projects")

    expect(page).to have_content "This is an edited project"

    login(other_team_account)

    visit("/projects")

    expect(page).not_to have_content "This is an edited project"

    expect(page).to have_content "Public Project"

    click_link "View"

    expect(page).not_to have_content "Edit"
  end
end

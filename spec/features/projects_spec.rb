require "rails_helper"

describe "viewing projects, creating and editing", :js do
  let!(:project) { create(:project, title: "Project 1", description: "cats with lazers", owner_account: account, slack_team_id: "citizencode") }
  let!(:project2) { create(:project, title: "Public Project", owner_account: account, slack_team_id: "citizencode", public: true) }
  let!(:account) { create(:account).tap { |a| create(:authentication, account_id: a.id, slack_team_id: "citizencode") } }
  let!(:same_team_account) { create(:account).tap { |a| create(:authentication, account_id: a.id, slack_team_id: "citizencode") } }
  let!(:other_team_account) { create(:account).tap { |a| create(:authentication, account_id: a.id, slack_team_id: "comakery") } }

  describe "landing and searching" do
    it "shows some projects" do
      login(account)

      7.times {|i| create(:project, title: "Public Project #{i}", public: true, slack_team_name: "This is a slack team name") }
      7.times {|i| create(:project, title: "Private Project #{i}", public: false, slack_team_id: "citizencode", slack_team_name: "This is a slack team name") }

      visit root_path

      wut
      expect(page.all(".project").size).to eq(12)
      expect(page).to have_content "Public Project"
      expect(page).to have_content "This is a slack team name"

      click_link "Browse All"

      expect(page.all(".project").size).to eq(16)
      expect(page).to have_content "Public Project"
    end
  end

  specify do
    login(account)

    visit projects_path

    expect(page).to have_content "Project 1"

    within "#project-#{project.to_param}" do
      click_link project.title
    end

    click_link "Back"

    click_link "New Project"

    fill_in "Title", with: "This is a project"
    fill_in "Description", with: "This is a project description which is very informative"
    attach_file "Project Image", Rails.root.join("spec", "fixtures", "helmet_cat.png")
    expect(find_field("Set project as public (display in CoMakery index)")).to be_checked

    reward_type_inputs = page.all(".reward-type-row", visible: true)
    reward_type_inputs[0].all("input")[0].set "This is a small reward type"
    reward_type_inputs[0].all("input")[1].set "1000"
    reward_type_inputs[1].all("input")[0].set "This is a medium reward type"
    reward_type_inputs[1].all("input")[1].set "2000"
    reward_type_inputs[2].all("input")[0].set "This is a large reward type"
    reward_type_inputs[2].all("input")[1].set "3000"

    expect(reward_type_inputs.size).to eq(3)

    click_link "+ add reward type"

    reward_type_inputs = page.all(".reward-type-row", visible: true)
    expect(reward_type_inputs.size).to eq(4)
    reward_type_inputs[3].all("input")[0].set "This is a super big reward type"
    reward_type_inputs[3].all("input")[1].set "5000"

    click_link "+ add reward type"

    reward_type_inputs = page.all(".reward-type-row", visible: true)
    expect(reward_type_inputs.size).to eq(5)

    reward_type_inputs[4].all("a[data-mark-and-hide]")[0].click

    reward_type_inputs = page.all(".reward-type-row", visible: true)
    expect(reward_type_inputs.size).to eq(4)

    click_on "Save"

    expect(page).to have_content "Project created"
    expect(page).to have_content "This is a project"
    expect(page).to have_content "This is a project description which is very informative"
    expect(page.find(".project-image")[:src]).to match(/\/attachments\/[A-Za-z0-9\/]+\/image/)
    expect(page).not_to have_link "Project Tasks »"
    expect(page).to have_content "Visibility: Public"

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

    expect(page.find(".project-image")[:src]).to match(/\/attachments\/[A-Za-z0-9\/]+\/image/)

    expect(page).to have_checked_field("Set project as public (display in CoMakery index)")
    fill_in "Title", with: "This is an edited project"
    fill_in "Description", with: "This is an edited project description which is very informative"
    fill_in "Project Tracker", with: "http://github.com/here/is/my/tracker"
    uncheck "Set project as public (display in CoMakery index)"

    reward_type_inputs = page.all(".reward-type-row", visible: true)
    expect(reward_type_inputs.size).to eq(4)

    reward_type_inputs[0].all("a[data-mark-and-hide]")[0].click
    reward_type_inputs = page.all(".reward-type-row", visible: true)
    expect(reward_type_inputs.size).to eq(3)

    click_on "Save"

    expect(page).to have_content "Project updated"
    expect(page).to have_content "This is an edited project"
    expect(page).to have_content "This is an edited project description which is very informative"
    expect(page).to have_content "Visibility: Private"
    expect(page).to have_link "Project Tasks »"

    reward_type_inputs = page.all(".reward-type-row")
    expect(reward_type_inputs.size).to eq(3)
    expect(page).not_to have_content "This is a small reward type"
    expect(page).not_to have_content "1000"

    expect(reward_type_inputs.size).to eq(3)

    visit("/projects")

    expect(page).to have_content "This is an edited project"

    login(same_team_account)

    visit("/projects")

    expect(page).to have_content "This is an edited project"

    login(other_team_account)

    visit("/projects")

    expect(page).not_to have_content "This is an edited project"

    expect(page).to have_content "Public Project"

    click_link "Public Project"

    expect(page).not_to have_content "Edit"
  end
end

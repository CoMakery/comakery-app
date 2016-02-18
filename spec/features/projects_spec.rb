require "rails_helper"

describe "viewing projects, creating and editing" do
  let!(:project) { create :project, "Project 1" }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account_id: account.id }

  specify do
    page.set_rack_session(account_id: account.id)

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
    check "Public"

    page.find("input#project_reward_types_attributes_0_name").set "This is a small reward type"
    page.find("input#project_reward_types_attributes_0_suggested_amount").set "1000"

    click_on "Save"

    expect(page).to have_content "Project created"
    expect(page).to have_content "This is a project"
    expect(page).to have_content "This is a project description which is very informative"
    expect(page).to have_content "Visibility: Public"
    expect(page).to have_link "Project Tasks »"

    reward_type_rows = page.all(".reward-types .row")
    expect(reward_type_rows[0]).to have_content "This is a small reward type"
    expect(reward_type_rows[0]).to have_content "1000"

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
  end
end

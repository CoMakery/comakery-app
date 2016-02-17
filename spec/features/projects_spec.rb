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
    fill_in "Repository", with: "http://github.com/here/is/my/tracker"

    click_on "Save"

    expect(page).to have_content "Project created"
    expect(page).to have_content "This is a project"
    expect(page).to have_content "This is a project description which is very informative"
    expect(page).to have_content "http://github.com/here/is/my/tracker"
  end
end

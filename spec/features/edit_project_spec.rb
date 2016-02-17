require "rails_helper"

describe "editing a project" do
  let!(:project) { create :project }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account_id: account.id }

  specify do
    page.set_rack_session(account_id: account.id)

    visit project_path(project)

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

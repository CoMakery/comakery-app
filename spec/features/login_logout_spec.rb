require "rails_helper"

describe "logging in and out" do
  let!(:project) { create :project, title: "This is a project", owner_account: account }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account_id: account.id }

  specify do
    visit project_path(project)

    expect(page).to have_content "Log in"

    page.set_rack_session(account_id: account.id)

    visit project_path(project)

    expect(page).to have_content "This is a project"

    click_link "Log out"

    expect(page).to have_content "Log in"
  end
end

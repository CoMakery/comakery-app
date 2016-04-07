require "rails_helper"

describe "logging in and out" do
  let!(:project) { create :project, title: "This is a project", owner_account: account }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account_id: account.id }

  before { stub_slack_user_list }

  specify do
    page.set_rack_session(account_id: nil)

    visit root_path

    expect(page).to have_content "Sign in"

    page.set_rack_session(account_id: account.id)

    visit project_path(project)

    expect(page).to have_content "This is a project"

    click_link "Sign out"

    expect(page).to have_content "Sign in"

    visit "/logout"

    expect(page).to have_content "Sign in"
  end
end

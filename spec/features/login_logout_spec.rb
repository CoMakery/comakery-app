require "rails_helper"

describe "logging in and out", :vcr do
  let!(:project) { create :project, title: "This is a project", owner_account: account }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account_id: account.id }

  before do
    stub_request(:post, "https://slack.com/api/users.list").
        with(:body => {"token" => "slack token"},
             :headers => {'Accept' => 'application/json; charset=utf-8', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded'}).
        to_return(:status => 200, :body => {'ok' => true, 'members' => []}.to_json, :headers => {})
  end

  specify do
    page.set_rack_session(account_id: nil)

    visit root_path

    expect(page).to have_content "Sign in"

    page.set_rack_session(account_id: account.id)

    visit project_path(project)

    expect(page).to have_content "This is a project"

    click_link "Sign out"

    expect(page).to have_content "Sign in"
  end
end

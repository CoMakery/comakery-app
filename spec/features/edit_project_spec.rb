require "rails_helper"

describe "editing a project" do
  let!(:project) { create :project }
  let!(:account) { create :account }
  let!(:authentication) { create :authentication, account_id: account.id }

  specify do
    page.set_rack_session(account_id: account.id)

    visit project_path(project)
    expect(page).to have_content "New account"
  end
end

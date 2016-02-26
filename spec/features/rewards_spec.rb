require "rails_helper"

describe "viewing projects, creating and editing", :js do
  let!(:project) { create(:project, title: "Project that needs rewards", owner_account: owner_account) }

  let!(:small_reward_type) { create(:reward_type, project: project, name: "Small", amount: 1000) }
  let!(:large_reward_type) { create(:reward_type, project: project, name: "Large", amount: 3000) }

  let!(:owner_account) { create(:account, name: "Hubert").tap{|a| create(:authentication, account_id: a.id)} }
  let!(:other_account) { create(:account, name: "Sherman").tap{|a| create(:authentication, account_id: a.id)} }

  before do
    expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage)
  end

  specify do
    login(other_account)

    visit project_path(project)

    expect(page).not_to have_content("Send Reward")

    login(owner_account)

    visit project_path(project)

    choose "Small"

    expect(page.all("select#reward_account_id option").map(&:text).sort).to eq(["Hubert", "Sherman"])
    select "Sherman", from: "User"
    fill_in "Description", with: "Bob did super fantastic fabulous programatic work on teh things, A++"

    click_button "Send"

    expect(page).to have_content "Successfully sent reward to Sherman"
  end
end

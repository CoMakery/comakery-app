require "rails_helper"

describe "viewing projects, creating and editing", :js do
  let!(:project) { create(:project, title: "Project that needs rewards", owner_account: owner_account) }
  let!(:owner_account) { create(:account, name: "Hubert").tap{|a| create(:authentication, account_id: a.id)} }
  let!(:other_account) { create(:account, name: "Sherman").tap{|a| create(:authentication, account_id: a.id)} }

  specify do
    login(other_account)

    visit project_path(project)

    expect(page).not_to have_content("Send Reward")

    login(owner_account)

    visit project_path(project)

    click_link "Send Reward"

    expect(page).to have_content "Send Reward - Project that needs rewards"

    expect(page.all("select#reward_account_id option").map(&:text).sort).to eq(["Hubert", "Sherman"])

    select "Sherman", from: "User"
    fill_in "Amount", with: "3000"
    fill_in "Description", with: "Bob did super fantastic fabulous programatic work on teh things, A++"
    click_button "Send Reward"

    expect(page).to have_content "Successfully sent reward to Sherman"
  end
end

require 'rails_helper'

describe "Collaborator projects", :vcr do
  let!(:owner) { create(:account, email: "gleenn@example.com").tap { |a| create(:authentication, account: a, slack_team_id: "citizencode", slack_user_name: "owner", slack_first_name: "owner", slack_last_name: "owner", slack_user_id: "owner_id") } }
  let!(:collab1) { create(:account, email: "collab1@example.com").tap { |a| create(:authentication, account: a, slack_team_id: "citizencode", slack_user_name: "collab1", slack_first_name: "collab1", slack_last_name: "collab1", slack_user_id: "collab1") } }
  let!(:collab2) { create(:account, email: "collab2@example.com").tap { |a| create(:authentication, account: a, slack_team_id: "citizencode", slack_user_name: "collab2", slack_first_name: "collab2", slack_last_name: "collab2", slack_user_id: "collab2") } }

  it "allow creating of award types that are community-awardable" do
    stub_slack_channel_list
    stub_slack_user_list([create_stub_slack_user(first_name: "collab1", last_name: "collab1", user_id: "collab1"),
                          create_stub_slack_user(first_name: "collab2", last_name: "collab2", user_id: "collab2"),
                          create_stub_slack_user(first_name: "owner", last_name: "owner", user_id: "owner_id")])

    login(owner)

    visit root_path

    click_link "New Project"

    fill_in "Title", with: "Super title"
    fill_in "Description", with: "This is a project description which is very informative"
    attach_file "Project Image", Rails.root.join("spec", "fixtures", "helmet_cat.png")
    select "a channel name", from: "Slack Channel"

    award_type_inputs = get_award_type_rows
    expect(award_type_inputs.size).to eq(4)

    award_type_inputs[0].find("input[name*='[name]']").set "This will be a community awardable award"
    award_type_inputs[0].find("input[name*='[amount]']").set "10"
    award_type_inputs[0].find("input[name*='[community_awardable]'][type='checkbox']").set(true)

    click_on "Save"

    expect(page).to have_content "Project created"

    expect(page.all("select#award_slack_user_id option").map(&:text)).to match_array(["", "collab1 collab1 - @collab1collab1", "collab2 collab2 - @collab2collab2", "owner owner - @ownerowner"])

    bookmark_project_path = page.current_path

    login(collab1)

    visit bookmark_project_path

    expect(page.all("select#award_slack_user_id option").map(&:text)).to match_array(["", "collab2 collab2 - @collab2collab2", "owner owner - @ownerowner"])
  end
end
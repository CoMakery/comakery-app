require "rails_helper"

describe "", :js do
  let!(:owner) { create(:account) }
  let!(:owner_auth) { create(:authentication, account: owner, slack_team_id: "foo", slack_image_32_url: "http://avatar.com/owner.jpg") }
  let!(:other_account) { create(:account) }
  let!(:other_account_auth) { create(:authentication, account: other_account, slack_team_id: "foo", slack_image_32_url: "http://avatar.com/other.jpg") }
  let!(:project) { create(:project, public: true, owner_account: owner, slack_team_id: "foo") }
  let!(:award_type) { create(:award_type, project: project, community_awardable: false, amount: 1000) }
  let!(:community_award_type) { create(:award_type, project: project, community_awardable: true, amount: 10) }
  let!(:award) { create(:award, award_type: award_type, issuer: owner, authentication: other_account_auth) }
  let!(:community_award) { create(:award, award_type: community_award_type, issuer: other_account, authentication: owner_auth) }

  before do
    stub_slack_user_list
    stub_slack_channel_list
  end

  it "project owner can record revenues" do
    login owner
    visit project_path(project)
    click_link "Revenues"

    fill_in :revenue_amount, with: 10
    fill_in :revenue_comment, with: "A comment"
    fill_in :revenue_transaction_reference, with: "0e3e2357e806b6cdb1f70b54c3a3a17b6714ee1f0e68bebb44a74b1efd512098"
    click_on "Record Revenue"

    within ".revenues" do
      expect(page.all('.transaction-reference')[0]).to have_content('0e3e2357e806b6cdb1f70b54c3a3a17b6714ee1f0e68bebb44a74b1efd512098')
      expect(page.all('.comment')[0]).to have_content('A comment')
      expect(page).to have_content('10.00 USD')
    end
  end

  it "non-project owner cannot record revenues" do
    login other_account

    visit project_path(project)
    click_link "Revenues"

    expect(page).to_not have_css('.new_revenue')
  end
end
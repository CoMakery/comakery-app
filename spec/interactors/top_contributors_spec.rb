require 'rails_helper'

describe TopContributors do
  describe "#call" do
    it "returns the map of project => accounts of the top N most awarded members, ordered by total contribution, excluding accounts without awards" do
      sb_account_owner = create(:sb_account, email: "sb_account_owner")
      sb_auth1 = create(:sb_authentication, slack_user_name: "sb1")
      sb_auth2 = create(:sb_authentication, slack_user_name: "sb2")
      sb_auth3 = create(:sb_authentication, slack_user_name: "sb3")
      sb_auth4 = create(:sb_authentication, slack_user_name: "sb4")

      sb_project = create(:sb_project, owner_account: sb_account_owner)

      create(:award, authentication: sb_auth1, award_type: create(:award_type, project: sb_project, amount: 500))
      create(:award, authentication: sb_auth1, award_type: create(:award_type, project: sb_project, amount: 500))
      create(:award, authentication: sb_auth1, award_type: create(:award_type, project: sb_project, amount: 500))
      create(:award, authentication: sb_auth2, award_type: create(:award_type, project: sb_project, amount: 1000))
      create(:award, authentication: sb_auth3, award_type: create(:award_type, project: sb_project, amount: 2000))
      create(:award, authentication: sb_auth4, award_type: create(:award_type, project: sb_project, amount: 10))

      expected_auths = %w(sb3 sb1 sb2)
      expect(TopContributors.call(projects: [sb_project], n: 3).contributors[sb_project].map{|auth|auth.slack_user_name}).to eq(expected_auths)
    end
  end
end
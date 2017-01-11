require 'rails_helper'

describe TopContributors do
  describe "#call" do
    before do
      travel_to(Date.new(2016, 6, 6))
    end

    it "returns the map of project => accounts of the top N most awarded members, ordered by total contribution/recency, excluding accounts without awards and defaults n to 5" do
      sb_account_owner = create(:sb_authentication).account
      sb_auth1 = create(:sb_authentication, slack_user_name: "sb1")
      sb_auth2 = create(:sb_authentication, slack_user_name: "sb2")
      sb_auth3 = create(:sb_authentication, slack_user_name: "sb3")
      sb_auth4 = create(:sb_authentication, slack_user_name: "sb4")
      sb_auth5 = create(:sb_authentication, slack_user_name: "sb5")
      sb_auth6 = create(:sb_authentication, slack_user_name: "sb6")

      sb_project = create(:sb_project, owner_account: sb_account_owner)

      small_award_type = create(:award_type, project: sb_project, amount: 10)
      medium_award_type = create(:award_type, project: sb_project, amount: 500)
      large_award_type = create(:award_type, project: sb_project, amount: 1000)
      extra_large_award_type = create(:award_type, project: sb_project, amount: 2000)

      create(:award, authentication: sb_auth1, award_type: medium_award_type, created_at: 5.days.ago)
      create(:award, authentication: sb_auth1, award_type: medium_award_type, created_at: 5.days.ago)
      create(:award, authentication: sb_auth1, award_type: large_award_type, created_at: 5.days.ago)

      create(:award, authentication: sb_auth2, award_type: large_award_type, quantity: 2, created_at: 1.days.ago)

      create(:award, authentication: sb_auth3, award_type: extra_large_award_type, created_at: 4.days.ago)

      create(:award, authentication: sb_auth4, award_type: small_award_type, created_at: 3.days.ago)

      create(:award, authentication: sb_auth5, award_type: small_award_type, created_at: 2.days.ago)

      expected_result = [["sb3", 2000, 4.days.ago], ["sb1", 2000, 5.days.ago], ["sb2", 2000, 1.days.ago]]
      expect(TopContributors.call(projects: [sb_project], n: 3).contributors[sb_project].map{|auth|[auth.slack_user_name, auth.total_awarded.to_i, auth.last_awarded_at]}).to eq(expected_result)

      expect(TopContributors.call(projects: [sb_project]).contributors[sb_project].map{|auth|auth.slack_user_name}).to eq(%w(sb3 sb1 sb2 sb5 sb4))
    end
  end
end

require 'rails_helper'

describe GetAwardableAuthentications do
  let!(:project) { create(:project, owner_account: project_owner) }
  let!(:project_owner) { create(:account) }
  let!(:project_owner_auth) { create(:authentication, account: project_owner, slack_user_id: "project_owner", slack_first_name: "project_owner", slack_last_name: "project_owner") }
  let(:other_auth) { create(:authentication, slack_user_id: "slack user id 1", slack_first_name: nil, slack_last_name: nil) }

  describe "#call" do
    it "returns some auths" do
      slack_double = double("slack")
      expect(Comakery::Slack).to receive(:get).and_return(slack_double)
      members = [
          {id: "U1119UVMH", team_id: "foo", name: "bobjohnson", profile: {first_name: "Bob", last_name: "Johnson", email: "bobjohnson@example.com"}},
          {id: "U2229UVMH", team_id: "foo", name: "bob", profile: {first_name: "Bob", last_name: "", email: "bobjohnson@example.com"}},
          {id: "U3339UVMH", team_id: "foo", name: "johnson", profile: {first_name: "", last_name: "Johnson", email: "bobjohnson@example.com"}},
          {id: "U8888UVMH", team_id: "foo", name: "receiver", profile: {email: "receiver@example.com"}},
          {id: "47", team_id: "foo", name: "blah", first_name: "", last_name: "", profile: {email: "receiver@example.com"}}
      ]
      expect(slack_double).to receive(:get_users).and_return(members: members)
      result = GetAwardableAuthentications.call(current_account: project_owner, project: project)
      expected = [
          ["@blah", "47"],
          ["Bob - @bob", "U2229UVMH"],
          ["Bob Johnson - @bobjohnson", "U1119UVMH"],
          ["Johnson - @johnson", "U3339UVMH"],
          ["@receiver", "U8888UVMH"]
      ]
      expect(result.awardable_authentications).to match_array(expected)
      expect(result.awardable_authentications).to eq(expected)
    end

    it "doesn't include the current_account if they are NOT the owner of the project" do
      slack_double = double("slack")
      expect(Comakery::Slack).to receive(:get).and_return(slack_double)
      expect(slack_double).to receive(:get_users).and_return(members: [{id: "slack user id 1",
                                                                        team_id: "foo",
                                                                        name: "bobjohnson",
                                                                        profile: {
                                                                            first_name: "Bob",
                                                                            last_name: "Johnson",
                                                                            email: "bobjohnson@example.com"
                                                                        }
                                                                       }])

      result = GetAwardableAuthentications.call(current_account: other_auth.account, project: project)
      expect(result.awardable_authentications).to eq([])
    end

    context "without a current user" do
      it "returns an empty array" do
        result = GetAwardableAuthentications.call(current_account: nil, project: nil, authentications: [])
        expect(result.awardable_authentications).to eq([])
      end
    end
  end
end

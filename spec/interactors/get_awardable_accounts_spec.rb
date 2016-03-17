require 'rails_helper'

describe GetAwardableAccounts do
  let(:current_account) { create(:account).tap { |a| create(:authentication, account: a) } }
  let(:account1) { create(:account).tap { |a| create(:authentication, account: a, slack_user_id: "slack user id 1", slack_first_name: nil, slack_last_name: nil) } }
  let(:account2) { create(:account).tap { |a| create(:authentication, account: a, slack_user_id: "slack user id 2", slack_first_name: "Joe", slack_last_name: "Bill") } }
  let(:account3) { create(:account).tap { |a| create(:authentication, account: a, slack_user_id: "slack user id 3", slack_first_name: "", slack_last_name: "") } }

  describe "#call" do
    it "returns some accounts" do
      slack_double = double("slack")
      expect(Comakery::Slack).to receive(:get).and_return(slack_double)
      members = [
       {id: "U1119UVMH",
        team_id: "foo",
        name: "bobjohnson",
        profile: {
            first_name: "Bob",
            last_name: "Johnson",
            email: "bobjohnson@example.com"
        }
       },
       {id: "U2229UVMH",
        team_id: "foo",
        name: "bob",
        profile: {
            first_name: "Bob",
            last_name: "",
            email: "bobjohnson@example.com"
        }
       },
       {id: "U3339UVMH",
        team_id: "foo",
        name: "johnson",
        profile: {
            first_name: "",
            last_name: "Johnson",
            email: "bobjohnson@example.com"
        }
       },
       {id: "U8888UVMH",
        team_id: "foo",
        name: "receiver",
        profile: {email: "receiver@example.com"}
       },
       {id: "47",
        team_id: "foo",
        name: "blah",
        first_name: "",
        last_name: "",
        profile: {
            email: "receiver@example.com"}
       }
     ]
      expect(slack_double).to receive(:get_users).and_return(members: members)
      result = GetAwardableAccounts.call(current_account: current_account, accounts: [account1, account2])
      expected = [
        ["@johndoe", "slack user id 1"],
        ["Joe Bill - @johndoe", "slack user id 2"],
        ["@blah", "47"],
        ["Bob Johnson - @bobjohnson", "U1119UVMH"],
        ["Bob - @bob", "U2229UVMH"],
        ["Johnson - @johnson", "U3339UVMH"],
        ["@receiver", "U8888UVMH"],
      ]
      expect(result.awardable_accounts).to eq(expected)
    end
  end
end

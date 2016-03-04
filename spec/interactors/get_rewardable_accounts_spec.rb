require 'rails_helper'

describe GetRewardableAccounts do
  let(:current_account) { create(:account).tap{|a| create(:authentication, account: a)} }
  let(:account1) { create(:account).tap{|a| create(:authentication, account: a, slack_user_id: "foo", slack_first_name: nil, slack_last_name: nil)} }
  let(:account2) { create(:account).tap{|a| create(:authentication, account: a, slack_user_id: "bar", slack_first_name: "Joe", slack_last_name: "Bill")} }

  describe "#call" do
    it "returns some accounts" do
      slack_double = double("slack")
      expect(Swarmbot::Slack).to receive(:get).and_return(slack_double)
      expect(slack_double).to receive(:get_users).and_return([{"id": "U9999UVMH",
                                                                       "team_id": "foo",
                                                                       "name": "bobjohnson",
                                                                       "profile": {
                                                                           "first_name": "Bob",
                                                                           "last_name": "Johnson",
                                                                           "email": "bobjohnson@example.com"
                                                                       }
                                                                      },
                                                                      {"id": "U8888UVMH",
                                                                       "team_id": "foo",
                                                                       "name": "receiver",
                                                                       "profile": {
                                                                           "email": "receiver@example.com"}
                                                                      }])

      result = GetRewardableAccounts.call(current_account: current_account, accounts: [account1, account2])
      expect(result.rewardable_accounts).to eq([["Joe Bill - johndoe", "bar"], ["johndoe", "foo"], ["receiver", "U8888UVMH"], ["Bob Johnson - bobjohnson", "U9999UVMH"]])
    end
  end
end

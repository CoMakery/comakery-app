require 'rails_helper'

describe AccountPolicy do
  let!(:team_foobar_account1) { create(:account).tap{|a| create(:authentication, account: a, slack_team_id: "foobar")} }
  let!(:team_foobar_account2) { create(:account).tap{|a| create(:authentication, account: a, slack_team_id: "foobar")} }
  let!(:team_fizzbuzz_account1) { create(:account).tap{|a| create(:authentication, account: a, slack_team_id: "fizzbuzz")} }

  describe AccountPolicy::Scope do
    it "returns accounts that belong to the same organization as the current user" do
      expect(AccountPolicy::Scope.new(team_foobar_account1, Account).resolve).to match_array([team_foobar_account1, team_foobar_account2])
    end

    it "returns nothing if account is nil" do
      expect(AccountPolicy::Scope.new(nil, Account).resolve).to eq([])
    end
  end
end

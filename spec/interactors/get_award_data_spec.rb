require 'rails_helper'

describe GetAwardData do
  describe "#call" do
    let!(:current_account) do
      create(:account, email: 'account@example.com').tap do |a|
        create(:authentication, account: a, slack_team_id: "foo", slack_user_name: "account", slack_user_id: "account slack_user_id", slack_team_domain: "foobar")
      end
    end

    let!(:project) { create(:project, title: "Cats", owner_account: current_account, slack_team_id: 'foo') }

    let!(:receiver_account) { create(:account, email: "receiver@example.com").tap { |a| create(:authentication, slack_user_id: "U8888UVMH", slack_team_id: "foo", account: a, slack_user_name: "receiver", slack_first_name: nil, slack_last_name: nil) } }
    let!(:other_account) { create(:account, email: "other@example.com").tap { |a| create(:authentication, slack_user_id: "other id", slack_team_id: "foo", account: a, slack_user_name: "other", slack_first_name: "Bob", slack_last_name: "Johnson") } }

    let!(:award_type1) { create(:award_type, project: project, amount: 1000, name: "Small Award") }
    let!(:award_type2) { create(:award_type, project: project, amount: 2000, name: "Medium Award") }
    let!(:award_type3) { create(:award_type, project: project, amount: 3000, name: "Big Award") }

    let!(:award0) { create(:award, award_type: award_type1, account: current_account) }

    let!(:award1) { create(:award, award_type: award_type1, account: receiver_account) }
    let!(:award2) { create(:award, award_type: award_type2, account: receiver_account) }
    let!(:award3) { create(:award, award_type: award_type3, account: receiver_account) }

    let!(:award4) { create(:award, award_type: award_type1, account: other_account) }
    let!(:award5) { create(:award, award_type: award_type2, account: other_account) }

    it "returns a pretty hash of the awards for a project with summed amounts for each person" do
      result = GetAwardData.call(current_account: current_account, project: project)

      expect(result.award_data[:pie_chart]).to match_array([{"name": "@receiver", "net_amount": 6000}, {"name": "Bob Johnson", "net_amount": 3000}, {name: "John Doe", net_amount: 1000}])
      expect(result.award_data[:award_amounts]).to eq({my_project_coins: 1000, total_coins_issued: 10_000})
    end
  end
end
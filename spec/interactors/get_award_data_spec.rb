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

    let!(:award0) { create(:award, award_type: award_type1, account: current_account, created_at: Date.new(2016, 1, 1)) }

    let!(:award1) { create(:award, award_type: award_type1, account: receiver_account, created_at: Date.new(2016, 3, 1)) }
    let!(:award2) { create(:award, award_type: award_type2, account: receiver_account, created_at: Date.new(2016, 3, 2)) }
    let!(:award3) { create(:award, award_type: award_type3, account: receiver_account, created_at: Date.new(2016, 3, 8)) }

    let!(:award4) { create(:award, award_type: award_type1, account: other_account, created_at: Date.new(2016, 3, 2)) }
    let!(:award5) { create(:award, award_type: award_type2, account: other_account, created_at: Date.new(2016, 3, 8)) }

    before do
      travel_to Date.new(2016, 3, 8)
    end

    it "doesn't explode if you aren't logged in" do
      result = GetAwardData.call(current_account: nil, project: project)
      expect(result.award_data[:award_amounts]).to eq({:my_project_coins => nil, :total_coins_issued => 10000})
    end

    it "returns a pretty hash of the awards for a project with summed amounts for each person" do
      result = GetAwardData.call(current_account: current_account, project: project)

      expect(result.award_data[:contributions]).to match_array([{name: "@receiver", net_amount: 6000},
                                                                {name: "Bob Johnson", net_amount: 3000},
                                                                {name: "John Doe", net_amount: 1000}])

      expect(result.award_data[:award_amounts]).to eq({my_project_coins: 1000, total_coins_issued: 10_000})

      expect(result.award_data[:contributions_by_day]).to eq([
                                                                 {date: "20160207", value: 0},
                                                                 {date: "20160208", value: 0},
                                                                 {date: "20160209", value: 0},
                                                                 {date: "20160210", value: 0},
                                                                 {date: "20160211", value: 0},
                                                                 {date: "20160212", value: 0},
                                                                 {date: "20160213", value: 0},
                                                                 {date: "20160214", value: 0},
                                                                 {date: "20160215", value: 0},
                                                                 {date: "20160216", value: 0},
                                                                 {date: "20160217", value: 0},
                                                                 {date: "20160218", value: 0},
                                                                 {date: "20160219", value: 0},
                                                                 {date: "20160220", value: 0},
                                                                 {date: "20160221", value: 0},
                                                                 {date: "20160222", value: 0},
                                                                 {date: "20160223", value: 0},
                                                                 {date: "20160224", value: 0},
                                                                 {date: "20160225", value: 0},
                                                                 {date: "20160226", value: 0},
                                                                 {date: "20160227", value: 0},
                                                                 {date: "20160228", value: 0},
                                                                 {date: "20160229", value: 0},
                                                                 {date: "20160301", value: 1000},
                                                                 {date: "20160302", value: 3000},
                                                                 {date: "20160303", value: 0},
                                                                 {date: "20160304", value: 0},
                                                                 {date: "20160305", value: 0},
                                                                 {date: "20160306", value: 0},
                                                                 {date: "20160307", value: 0},
                                                                 {date: "20160308", value: 5000}
                                                             ])
    end
  end

  describe "#contributions_data" do
    it "shows the email address if there aren't any auths" do
      account = create(:account, email: "caesar_salad@example.com")
      expect(account.authentications.count).to eq(0)
      award = create(:award, account: account)
      expect(GetAwardData.new.contributions_data([award])).to eq([{:net_amount => 1337, :name => "caesar_salad@example.com"}])
    end
  end
end
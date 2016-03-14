require 'rails_helper'

describe GetAwardData do
  let!(:sam) do
    create(:account, email: 'account@example.com').tap do |a|
      create(:authentication, account: a, slack_first_name: "sam", slack_last_name: "sam", slack_team_id: "foo", slack_user_name: "account", slack_user_id: "account slack_user_id", slack_team_domain: "foobar")
    end
  end
  let!(:john) { create(:account, email: "receiver@example.com").tap { |a| create(:authentication, slack_user_id: "U8888UVMH", slack_team_id: "foo", account: a, slack_user_name: "john", slack_first_name: nil, slack_last_name: nil) } }
  let!(:bob) { create(:account, email: "other@example.com").tap { |a| create(:authentication, slack_first_name: "bob", slack_last_name: "bob", slack_user_id: "other id", slack_team_id: "foo", account: a, slack_user_name: "other") } }

  let!(:project) { create(:project, title: "Cats", owner_account: sam, slack_team_id: 'foo') }

  let!(:award_type1) { create(:award_type, project: project, amount: 1000, name: "Small Award") }
  let!(:award_type2) { create(:award_type, project: project, amount: 2000, name: "Medium Award") }
  let!(:award_type3) { create(:award_type, project: project, amount: 3000, name: "Big Award") }

  describe "#call" do
    let!(:sam_award_1) { create(:award, award_type: award_type1, account: sam, created_at: Date.new(2016, 1, 1)) }

    let!(:john_award_1) { create(:award, award_type: award_type1, account: john, created_at: Date.new(2016, 2, 8)) }
    let!(:john_award_2) { create(:award, award_type: award_type1, account: john, created_at: Date.new(2016, 3, 1)) }
    let!(:john_award_3) { create(:award, award_type: award_type2, account: john, created_at: Date.new(2016, 3, 2)) }
    let!(:john_award_4) { create(:award, award_type: award_type3, account: john, created_at: Date.new(2016, 3, 8)) }

    let!(:bob_award_1) { create(:award, award_type: award_type1, account: bob, created_at: Date.new(2016, 3, 2)) }
    let!(:bob_award_2) { create(:award, award_type: award_type2, account: bob, created_at: Date.new(2016, 3, 8)) }

    before do
      travel_to Date.new(2016, 3, 8)
    end

    it "doesn't explode if you aren't logged in" do
      result = GetAwardData.call(current_account: nil, project: project)
      expect(result.award_data[:award_amounts]).to eq({:my_project_coins => nil, :total_coins_issued => 10000})
    end

    it "returns a pretty hash of the awards for a project with summed amounts for each person" do
      result = GetAwardData.call(current_account: sam, project: project)

      expect(result.award_data[:contributions]).to match_array([{name: "@john", net_amount: 6000},
                                                                {name: "bob bob", net_amount: 3000},
                                                                {name: "sam sam", net_amount: 1000}])

      expect(result.award_data[:award_amounts]).to eq({my_project_coins: 1000, total_coins_issued: 10_000})
    end

    it "shows values for each contributor for all 30 days" do
      result = GetAwardData.call(current_account: sam, project: project)

      awarded_account_names = Award.select("account_id, max(id) as id").group("account_id").all.map { |a| a.account.slack_auth.display_name }
      expect(awarded_account_names).to match_array(["@john", "sam sam", "bob bob"])

      expect(result.award_data[:contributions_by_day]).to eq([{"date"=>"2016-02-07", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-08", "@john"=>1000, "bob bob"=>0},
                                                              {"date"=>"2016-02-09", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-10", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-11", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-12", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-13", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-14", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-15", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-16", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-17", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-18", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-19", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-20", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-21", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-22", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-23", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-24", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-25", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-26", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-27", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-28", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-02-29", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-03-01", "@john"=>1000, "bob bob"=>0},
                                                              {"date"=>"2016-03-02", "@john"=>2000, "bob bob"=>1000},
                                                              {"date"=>"2016-03-03", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-03-04", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-03-05", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-03-06", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-03-07", "@john"=>0, "bob bob"=>0},
                                                              {"date"=>"2016-03-08", "@john"=>3000, "bob bob"=>2000}])
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

  describe "#contributor_by_day_row" do
    let!(:bobs_award) { create(:award, award_type: award_type1, account: bob, created_at: Date.new(2016, 3, 2)) }
    let!(:johns_award) { create(:award, award_type: award_type2, account: john, created_at: Date.new(2016, 3, 2)) }

    it "returns a row of data with defaults for missing data and summed amounts for multiple awards on the sam same day" do
      interactor = GetAwardData.new
      template = {"bob bob" => 0, "sam sam" => 0, "@john" => 0, "some other guy" => 0}.freeze
      expect(interactor.contributor_by_day_row(template, "20160302", [johns_award, bobs_award])).to eq({"@john" => 2000,
                                                                                                        "bob bob" => 1000,
                                                                                                        "some other guy" => 0,
                                                                                                        "sam sam" => 0,
                                                                                                        "date" => "20160302"})
    end
  end
end

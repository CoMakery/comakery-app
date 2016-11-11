require 'rails_helper'

describe GetAwardData do
  let!(:sam) { create(:account, email: 'account@example.com') }
  let!(:sam_auth) { create(:authentication, account: sam, slack_first_name: "sam", slack_last_name: "sam", slack_team_id: "foo", slack_user_name: "account", slack_user_id: "account slack_user_id", slack_team_domain: "foobar", slack_image_32_url: "http://avatar.com/im_pretty.jpg") }
  let!(:john) { create(:account, email: "receiver@example.com") }
  let!(:john_auth) { create(:authentication, slack_user_id: "U8888UVMH", slack_team_id: "foo", account: john, slack_user_name: "john", slack_first_name: nil, slack_last_name: nil) }
  let!(:bob) { create(:account, email: "other@example.com") }
  let!(:bob_auth) { create(:authentication, slack_first_name: "bob", slack_last_name: "bob", slack_user_id: "other id", slack_team_id: "foo", account: bob, slack_user_name: "other") }

  let!(:project) { create(:project, title: "Cats", owner_account: sam, slack_team_id: 'foo') }

  let!(:award_type1) { create(:award_type, project: project, amount: 1000, name: "Small Award") }
  let!(:award_type2) { create(:award_type, project: project, amount: 2000, name: "Medium Award") }
  let!(:award_type3) { create(:award_type, project: project, amount: 3000, name: "Big Award") }

  describe "#call" do
    let!(:sam_award_1) { create(:award, award_type: award_type1, authentication: sam_auth, created_at: Date.new(2016, 1, 1)) }

    let!(:john_award_1) { create(:award, award_type: award_type1, authentication: john_auth, created_at: Date.new(2016, 2, 8)) }
    let!(:john_award_2) { create(:award, award_type: award_type1, authentication: john_auth, created_at: Date.new(2016, 3, 1)) }
    let!(:john_award_3) { create(:award, award_type: award_type2, authentication: john_auth, created_at: Date.new(2016, 3, 2)) }
    let!(:john_award_4) { create(:award, award_type: award_type3, authentication: john_auth, created_at: Date.new(2016, 3, 8)) }

    let!(:bob_award_1) { create(:award, award_type: award_type1, authentication: bob_auth, created_at: Date.new(2016, 3, 2)) }
    let!(:bob_award_2) { create(:award, award_type: award_type2, authentication: bob_auth, created_at: Date.new(2016, 3, 8)) }

    before do
      travel_to Date.new(2016, 3, 8)
    end

    it "doesn't explode if you aren't logged in" do
      result = GetAwardData.call(authentication: nil, project: project)
      expect(result.award_data[:award_amounts]).to eq({:my_project_coins => nil, :total_coins_issued => 11000})
    end

    it "returns a pretty hash of the awards for a project with summed amounts for each person" do
      result = GetAwardData.call(authentication: sam_auth, project: project)

      expect(result.award_data[:contributions]).to match_array([{:net_amount=>7000, :name=>"@john", :avatar=>"https://slack.example.com/team-image-34-px.jpg"},
                                                                {:net_amount=>3000, :name=>"bob bob", :avatar=>"https://slack.example.com/team-image-34-px.jpg"},
                                                                {:net_amount=>1000, :name=>"sam sam", :avatar=>"http://avatar.com/im_pretty.jpg"}])

      expect(result.award_data[:award_amounts]).to eq({my_project_coins: 1000, total_coins_issued: 11_000})
    end

    it "shows values for each contributor for all 30 days" do
      result = GetAwardData.call(current_account: sam, project: project)

      awarded_account_names = Award.select("authentication_id, max(id) as id").group("authentication_id").all.map { |a| a.authentication.display_name }
      expect(awarded_account_names).to match_array(["@john", "sam sam", "bob bob"])

      contributions = result.award_data[:contributions_by_day].select do |cbd|
        cbd["@john"] > 0
      end

      expect(contributions).to eq([
                                      {"date" => "2016-02-08", "sam sam" => 0, "@john" => 1000, "bob bob" => 0},
                                      {"date" => "2016-03-01", "sam sam" => 0, "@john" => 1000, "bob bob" => 0},
                                      {"date" => "2016-03-02", "sam sam" => 0, "@john" => 2000, "bob bob" => 1000},
                                      {"date" => "2016-03-08", "sam sam"=>0, "@john" => 3000, "bob bob" => 2000}])
    end
  end

  describe "#contributions_data" do
    it "sorts by amount" do
      expect(GetAwardData.new.contributions_data([
                                                     create(:award, award_type: create(:award_type, amount: 1000), authentication: create(:authentication, slack_first_name: "a", slack_last_name: "a")),
                                                     create(:award, award_type: create(:award_type, amount: 3000), authentication: create(:authentication, slack_first_name: "b", slack_last_name: "b")),
                                                     create(:award, award_type: create(:award_type, amount: 2000), authentication: create(:authentication, slack_first_name: "c", slack_last_name: "c"))
                                                 ])).to eq([{:net_amount=>3000, :name=>"b b", :avatar=>"https://slack.example.com/team-image-34-px.jpg"},
                                                            {:net_amount=>2000, :name=>"c c", :avatar=>"https://slack.example.com/team-image-34-px.jpg"},
                                                            {:net_amount=>1000, :name=>"a a", :avatar=>"https://slack.example.com/team-image-34-px.jpg"}])
    end
  end

  describe "#contributions_summary_data" do
    it "gathers extra entries into 'other'" do
      expect(GetAwardData.new.contributions_summary_data([
                                                     create(:award, award_type: create(:award_type, amount: 10), authentication: create(:authentication, slack_first_name: "a", slack_last_name: "a")),
                                                     create(:award, award_type: create(:award_type, amount: 33), authentication: create(:authentication, slack_first_name: "b", slack_last_name: "b")),
                                                     create(:award, award_type: create(:award_type, amount: 20), authentication: create(:authentication, slack_first_name: "c", slack_last_name: "c"))
                                                 ], 1)).to eq([
                                                               {:net_amount => 33, :name => "b b", :avatar=>"https://slack.example.com/team-image-34-px.jpg"},
                                                               {:net_amount => 30, :name => "Other"}
                                                           ])
    end
    it "gathers shows all entries if less than threshold" do
      expect(GetAwardData.new.contributions_summary_data([
                                                     create(:award, award_type: create(:award_type, amount: 10), authentication: create(:authentication, slack_first_name: "a", slack_last_name: "a")),
                                                     create(:award, award_type: create(:award_type, amount: 33), authentication: create(:authentication, slack_first_name: "b", slack_last_name: "b")),
                                                     create(:award, award_type: create(:award_type, amount: 20), authentication: create(:authentication, slack_first_name: "c", slack_last_name: "c"))
                                                 ], 3)).to eq([
                                                               {:net_amount => 33, :name => "b b", :avatar=>"https://slack.example.com/team-image-34-px.jpg"},
                                                               {:net_amount => 20, :name => "c c", :avatar=>"https://slack.example.com/team-image-34-px.jpg"},
                                                               {:net_amount => 10, :name => "a a", :avatar=>"https://slack.example.com/team-image-34-px.jpg"},
                                                           ])
    end
  end

  describe "#contributor_by_day_row" do
    let!(:bobs_award) { create(:award, award_type: award_type1, authentication: bob_auth, created_at: Date.new(2016, 3, 2)) }
    let!(:johns_award) { create(:award, award_type: award_type2, authentication: john_auth, created_at: Date.new(2016, 3, 2)) }
    let!(:johns_award2) { create(:award, award_type: award_type2, authentication: john_auth, created_at: Date.new(2016, 3, 2)) }

    it "returns a row of data with defaults for missing data and summed amounts for multiple awards on the sam same day" do
      interactor = GetAwardData.new
      template = {"bob bob" => 0, "sam sam" => 0, "@john" => 0, "some other guy" => 0}.freeze
      expect(interactor.contributor_by_day_row(template, "20160302", [johns_award, johns_award2, bobs_award])).to eq({"@john" => 4000,
                                                                                                        "bob bob" => 1000,
                                                                                                        "some other guy" => 0,
                                                                                                        "sam sam" => 0,
                                                                                                        "date" => "20160302"})
    end
  end
end

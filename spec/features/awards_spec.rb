require "rails_helper"

describe "viewing projects, creating and editing", :js, :vcr do
  context "when not owner" do
    let!(:owner) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: "foo") } }
    let!(:other_account) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: "foo") } }
    let!(:project) { create(:project, public: true, owner_account: owner, slack_team_id: "foo") }
    let!(:award_type) { create(:award_type, project: project, community_awardable: false) }
    let!(:community_award_type) { create(:award_type, project: project, community_awardable: true) }

    before do
      stub_slack_user_list
      stub_slack_channel_list
    end

    context "when logged in as non-owner" do
      context "viewing projects" do
        before { login(other_account) }

        it "shows radio buttons for community awardable awards" do
          visit project_path(project)

          within(".award-types") do
            expect(page.all("input[type=radio]").size).to eq(2)
            expect(page.all("input[type=radio][disabled=disabled]").size).to eq(1)
            expect(page).to have_content "User"
            expect(page).to have_content "Description"
          end
        end
      end
    end

    context "when logged out" do
      context "viewing projects" do
        it "doesn't show forms for awarding" do
          visit project_path(project)

          within(".award-types") do
            expect(page.all("input[type=radio]").size).to eq(0)
            expect(page.all("input[type=radio][disabled=disabled]").size).to eq(0)
            expect(page).not_to have_content "User"
            expect(page).not_to have_content "Description"
          end
        end
      end

      context "viewing awards" do
        let!(:award) { create(:award, award_type: community_award_type) }

        it "lets people view awards" do
          visit project_path(project)

          click_link "Award History »"

          expect(page).to have_content "Award History"
        end
      end
    end
  end

  context "awarding users" do
    let!(:project) { create(:project, title: "Project that needs awards", owner_account: owner_account, slack_team_id: "team id") }
    let!(:same_team_project) { create(:project, title: "Same Team Project", owner_account: owner_account, slack_team_id: "team id") }
    let!(:different_team_project) { create(:project, public: true, title: "Different Team Project", owner_account: owner_account, slack_team_id: "team id") }

    let!(:small_award_type) { create(:award_type, project: project, name: "Small", amount: 1000) }
    let!(:large_award_type) { create(:award_type, project: project, name: "Large", amount: 3000) }

    let!(:same_team_small_award_type) { create(:award_type, project: same_team_project, name: "Small", amount: 10) }
    let!(:same_team_small_award) { create(:award, account: owner_account, award_type: same_team_small_award_type) }

    let!(:different_large_award_type) { create(:award_type, project: different_team_project, name: "Large", amount: 3000) }
    let!(:different_large_award) { create(:award, award_type: different_large_award_type) }

    let!(:owner_account) { create(:account, email: "hubert@example.com").tap { |a| create(:authentication, slack_user_name: 'hubert', slack_first_name: 'Hubert', slack_last_name: 'Sherbert', slack_user_id: 'hubert id', account_id: a.id, slack_team_id: "team id") } }
    let!(:other_account) { create(:account, email: "sherman@example.com").tap { |a| create(:authentication, slack_user_name: 'sherman', slack_user_id: 'sherman id', slack_first_name: "Sherman", slack_last_name: "Yessir", account_id: a.id, slack_team_id: "team id") } }
    let!(:different_team_account) { create(:account, email: "different@example.com").tap { |a| create(:authentication, slack_user_name: 'different', slack_user_id: 'different id', slack_first_name: "Different", slack_last_name: "Different", account_id: a.id, slack_team_id: "different team id") } }

    before do
      travel_to(DateTime.parse("Mon, 29 Feb 2016 00:00:00 +0000"))

      expect_any_instance_of(Account).to receive(:send_award_notifications)
      stub_request(:post, "https://slack.com/api/users.list").to_return(body: {ok: true,
                                                                               members: [{"id": "U99M9QYFQ",
                                                                                          "team_id": "team id",
                                                                                          "name": "bobjohnson",
                                                                                          "profile": {"email": "bobjohnson@example.com"}
                                                                                         }]}.to_json)
      stub_request(:post, "https://slack.com/api/users.info").to_return(body: {
          ok: true,
          "user": {
              "id": "U99M9QYFQ",
              "team_id": "team id",
              "name": "bobjohnson",
              "profile": {
                  email: "bobjohnson@example.com"
              }

          }
      }.to_json)
    end

    after do
      travel_back
    end

    describe "awarding a user which swarmbot doesn't have an account for yet" do
      it "populates the dropdown to select the awardee and creates the account/auth for the user" do
        login(owner_account)

        visit project_path(project)

        expect(page).to have_content "0 My Project Coins"

        choose "Small"
        expect(page.all("select#award_slack_user_id option").map(&:text).sort).to eq(["", "@bobjohnson", "Hubert Sherbert - @hubert", "Sherman Yessir - @sherman"])
        select "bobjohnson", from: "User"

        click_button "Send"

        expect(page).to have_content "Successfully sent award to @bobjohnson"

        bobjohnsons_auth = Authentication.find_by(slack_user_name: "bobjohnson")
        expect(bobjohnsons_auth).not_to be_nil

        login(bobjohnsons_auth.account)

        visit project_awards_path(bobjohnsons_auth.projects.first)

        expect(page).to have_content "@bobjohnson"

        click_link("Back to project")

        expect(page).to have_content "0 My Project Coins"
        expect(page).to have_content "1000 Total Coins Issued"

        expect(page).to have_content "1000 @bobjohnson"

        expect(page.html).to include('{"content": [{"label":"@bobjohnson","value":1000}')
      end
    end

    it "has a working happy path" do
      login(other_account)

      visit project_path(project)

      expect(page).to have_content("Project that needs awards")
      expect(page).not_to have_content("Send Award")
      expect(page).not_to have_content("User")

      login(owner_account)

      visit project_path(project)

      click_link "Award History »"

      expect(page.all(".award-rows .award-row").size).to eq(0)

      expect(page).to have_content("Award History")

      click_link "Back to project"

      expect(page).to have_content("Project that needs awards")

      click_button "Send"

      expect(page).to have_content "Failed sending award"

      choose "Small"

      within(".award-types") do
        expect(page.all("input[type=radio]").size).to eq(2)
        expect(page.all("input[type=radio][disabled=disabled]").size).to eq(0)
      end

      expect(page.all("select#award_slack_user_id option").map(&:text).sort).to eq(["", "@bobjohnson", "Hubert Sherbert - @hubert", "Sherman Yessir - @sherman"])
      select "@sherman", from: "User"
      fill_in "Description", with: "Super fantastic fabulous programatic work on teh things, A++"

      click_button "Send"

      expect(page).to have_content "Successfully sent award to Sherman Yessir"

      click_link "Award History »"

      expect(page).to have_content "Award History"
      expect(page).to have_content "Feb 29"
      expect(page).to have_content "1,000"
      expect(page).to have_content "Small"
      expect(page).to have_content "Super fantastic fabulous programatic work on teh things, A++"
      expect(page).to have_content "Hubert Sherbert"

      expect(page.all(".award-rows .award-row").size).to eq(1)

      click_link "Back to project"

      expect(page).to have_content("Project that needs awards")
    end
  end
end

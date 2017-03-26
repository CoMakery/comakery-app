require "rails_helper"

describe "viewing projects, creating and editing", :js do
  context "when not owner" do
    let!(:owner) { create(:account) }
    let!(:owner_auth) { create(:authentication, account: owner, slack_team_id: "foo", slack_image_32_url: "http://avatar.com/owner.jpg") }
    let!(:other_account) { create(:account) }
    let!(:other_account_auth) { create(:authentication, account: other_account, slack_team_id: "foo", slack_image_32_url: "http://avatar.com/other.jpg") }
    let!(:project) { create(:project, public: true, owner_account: owner, slack_team_id: "foo") }
    let!(:award_type) { create(:award_type, project: project, community_awardable: false, amount: 1000) }
    let!(:community_award_type) { create(:award_type, project: project, community_awardable: true, amount: 10) }
    let!(:award) { create(:award, award_type: award_type, issuer: owner, authentication: other_account_auth) }
    let!(:community_award) { create(:award, award_type: community_award_type, issuer: other_account, authentication: owner_auth) }

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
        it "lets people view awards" do
          visit project_path(project)

          click_link "Awards"
          expect(page).to have_content "Revenue Shares Awarded"
        end

        it 'paginates when there are lots of awards' do
          (60 - project.awards.count).times do
            create(:award, award_type: community_award_type, issuer: other_account, authentication: owner_auth)
          end

          visit project_path(project)

          click_link "Awards"
          expect(page.all("table.award-rows tr.award-row").size).to eq(50)

          within(page.all('.pagination').first) do
            click_link "2"
          end
          expect(page.all("table.award-rows tr.award-row").size).to eq(10)
        end
      end
    end
  end
end

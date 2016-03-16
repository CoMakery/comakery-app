require "rails_helper"

describe "viewing projects, creating and editing", :js, :vcr do
  let!(:project) { create(:project, title: "Cats with Lazers Project", description: "cats with lazers", owner_account: account, slack_team_id: "citizencode", public: false) }
  let!(:public_project) { create(:project, title: "Public Project", description: "dogs with donuts", owner_account: account, slack_team_id: "citizencode", public: true) }
  let!(:public_project_award) { create(:award, award_type: create(:award_type, project: public_project), created_at: Date.new(2016, 1, 9)) }
  let!(:account) { create(:account, email: "gleenn@example.com").tap { |a| create(:authentication, account_id: a.id, slack_team_id: "citizencode", slack_team_name: "Citizen Code", slack_team_image_34_url: "https://slack.example.com/awesome-team-image-34-px.jpg", slack_user_name: 'gleenn', slack_first_name: "Glenn", slack_last_name: "Spanky", slack_team_domain: "citizencodedomain") } }

  describe "while logged out" do
    it "allows viewing public projects index and show" do
      visit root_path

      within(".top-bar .slack-instance") do
        expect(page).not_to have_content "Citizen Code"
        expect(page).not_to have_content "CoMakery"
      end

      expect(page).not_to have_content "My Projects"

      expect(page).not_to have_content "Cats with Lazers Project"
      expect(page).to have_content "Public Project"

      expect(page).not_to have_content "New Project"

      click_link "Public Project"

      expect(page).to have_current_path(project_path(public_project))

      expect(page).to have_content "Public Project"
      expect(page).to have_content "Visibility: Public"
      expect(page).to have_content "Citizen Code"

      click_link "Back"

      click_link "Browse All"

      expect(page).to have_content "Public Project"
    end

    it "allows searching" do
      visit root_path
      fill_in "query", with: "public"
      click_on "Search"
      expect(page).to have_content "Public Project"
    end
  end
end

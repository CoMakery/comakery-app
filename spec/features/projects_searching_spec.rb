require "rails_helper"

describe "viewing projects, creating and editing", :js, :vcr do
  let!(:project) { create(:project, title: "Cats with Lazers Project", description: "cats with lazers", owner_account: account, slack_team_id: "citizencode", public: false) }
  let!(:public_project) { create(:project, title: "Public Project", description: "dogs with donuts", owner_account: account, slack_team_id: "citizencode", public: true) }
  let!(:public_project_award) { create(:award, award_type: create(:award_type, project: public_project), created_at: Date.new(2016, 1, 9)) }
  let!(:account) { create(:account, email: "gleenn@example.com").tap { |a| create(:authentication, account_id: a.id, slack_team_id: "citizencode", slack_team_name: "Citizen Code", slack_team_image_34_url: "https://slack.example.com/awesome-team-image-34-px.jpg", slack_team_image_132_url: "https://slack.example.com/awesome-team-image-132-px.jpg", slack_user_name: 'gleenn', slack_first_name: "Glenn", slack_last_name: "Spanky", slack_team_domain: "citizencodedomain") } }

  before do
    travel_to Date.new(2016, 1, 10)
  end

  context "with projects with recent awards" do
    let!(:birds_project) { create(:project, title: "Birds with Shoes Project", description: "birds with shoes", owner_account: account, slack_team_id: "comakery", public: true) }
    let!(:birds_project_award) { create(:award, award_type: create(:award_type, project: birds_project), created_at: Date.new(2016, 1, 8)) }

    it "allows searching and shows results based on projects that are most recently awarded" do
      login(account)

      visit projects_path

      expect(page).not_to have_content("Search results for")

      fill_in "query", with: "cats"

      click_on "Search"

      expect(page).to have_content "Citizen Code Projects"
      expect(page).to have_content 'There was 1 search result for: "cats"'
      expect(page).to have_content "Cats with Lazers Project"
      expect(page).not_to have_content "Public Project"

      fill_in "query", with: "s"

      click_on "Search"

      expect(page).to have_content "Citizen Code Projects"
      expect(page).to have_content 'There were 3 search results for: "s"'

      expect(page.all("a.project-link").map { |project_link| project_link.text }).to eq(["Public Project", "Birds with Shoes Project", "Cats with Lazers Project"])
      expect(page.all(".project-last-award").map { |project_link| project_link.text }).to eq(["last activity 1 day ago", "last activity 2 days ago"])

      title_and_highlightedness = page.all(".project").map { |project| [project.find("a.project-link").text, project[:class].include?("project-highlighted")] }
      expect(title_and_highlightedness).to eq([["Public Project", true], ["Birds with Shoes Project", false], ["Cats with Lazers Project", true]])

      click_link "Browse All"

      expect(page).to have_content "Citizen Code Projects"
    end
  end
end

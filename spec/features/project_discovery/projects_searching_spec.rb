require 'rails_helper'

describe 'viewing projects, creating and editing', :js do
  let!(:team) { create :team }
  let!(:project) { create(:project, title: 'Cats with Lazers Project', description: 'cats with lazers', account: account, public: false) }
  let!(:public_project) { create(:project, title: 'Public Project', description: 'dogs with donuts', account: account, visibility: 'public_listed') }
  let!(:public_project_award) { create(:award, award_type: create(:award_type, project: public_project), created_at: Date.new(2016, 1, 9)) }
  let!(:account) { create(:account, email: 'gleenn@example.com') }
  let!(:authentication) { create(:authentication, account: account) }

  before do
    team.build_authentication_team authentication
    travel_to Date.new(2016, 1, 10)
  end

  context 'with projects with recent awards' do
    let!(:birds_project) { create(:project, title: 'Birds with Shoes Project', description: 'birds with shoes', account: create(:account), visibility: 'public_listed') }
    let!(:birds_project_award) { create(:award, award_type: create(:award_type, project: birds_project), created_at: Date.new(2016, 1, 8)) }

    it 'allows searching and shows results based on projects that are most recently awarded' do
      login(account)

      visit projects_path

      expect(page).not_to have_content('Search results for')

      fill_in 'query', with: 'cats'

      click_on 'Search'

      within('h2') { expect(page.text).to eq('Projects') }
      expect(page).to have_content 'There was 1 search result for: "cats"'
      expect(page).to have_content 'Cats with Lazers Project'
      expect(page).not_to have_content 'Public Project'

      fill_in 'query', with: 's'

      click_on 'Search'

      within('h2') { expect(page.text).to eq('Projects') }
      expect(page).to have_content 'There were 3 search results for: "s"'

      expect(page.all('a.project-link').map(&:text)).to eq(['Public Project', 'Birds with Shoes Project', 'Cats with Lazers Project'])

      title_and_highlightedness = page.all('.project').map { |project| [project.find('a.project-link').text, project[:class].include?('project-highlighted')] }
      expect(title_and_highlightedness).to eq([['Public Project', true], ['Birds with Shoes Project', false], ['Cats with Lazers Project', true]])

      click_link 'Browse All'

      within('h2') { expect(page.text).to eq('Projects') }
    end
  end
end

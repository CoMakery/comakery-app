require 'rails_helper'

describe 'viewing projects, creating and editing', :js do
  let!(:team) { create :team }
  let!(:project) { create(:project, title: 'Cats with Lazers Project', description: 'cats with lazers', account: account) }
  let!(:public_project) { create(:project, title: 'Public Project', description: 'dogs with donuts', account: account, visibility: 'public_listed') }
  let!(:public_project_award) { create(:award, award_type: create(:award_type, project: public_project), created_at: Date.new(2016, 1, 9)) }
  let!(:account) { create(:account, email: 'gleenn@example.com') }
  let!(:authentication) { create(:authentication, account: account) }

  before do
    team.build_authentication_team authentication
  end

  describe 'while logged out' do
    it 'allows viewing public projects index and show' do
      visit mine_project_path

      expect(page).not_to have_content 'My Projects'

      expect(page).not_to have_content 'Cats with Lazers Project'
      expect(page).to have_content 'Public Project'

      expect(page).not_to have_content 'New Project'

      click_link 'Public Project'

      expect(page).to have_current_path(project_path(public_project))

      expect(page).to have_content 'Public Project'
    end
  end
end

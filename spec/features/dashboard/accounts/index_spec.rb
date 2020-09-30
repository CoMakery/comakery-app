require 'rails_helper'

describe 'project accounts page', js: true do
  let!(:project) { create(:project, visibility: :public_listed) }

  context 'with a token assigned to project' do
    it 'loads' do
      visit project_dashboard_accounts_path(project)
      expect(page).to have_css('.project_settings__content')
    end
  end

  context 'without a token assigned to project' do
    before do
      project.update(token: nil)
    end

    it 'loads' do
      visit project_dashboard_accounts_path(project)
      expect(page).to have_css('.project_settings__content')
    end
  end
end

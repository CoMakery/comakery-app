require 'rails_helper'

describe 'Award Types index', skip: true do
  context 'when project' do
    let(:project) { create :project }

    before do
      login(project.account)

      visit project_award_types_path(project)
    end

    context 'without mission' do
      it { expect(page).to have_current_path(project_award_types_path(project)) }
    end

    context 'with non-whitelabel mission' do
      before { project.update(mission: build(:mission) ) }

      it { expect(page).to have_current_path(project_award_types_path(project)) }
    end

    context 'with whitelabel mission and project awards hidden' do
      let(:whitelabel_mission) { create :whitelabel_mission, whitelabel_domain: 'www.example.com' }

      before { project.update(mission: whitelabel_mission ) }

      it { expect(page).to have_current_path(root_path) }
    end

    context 'with whitelabel mission and project awards visible' do
      before { project.mission.update(project_awards_visible: true ) }

      it { expect(page).to have_current_path(project_award_types_path(project)) }
    end
  end
end

require 'rails_helper'

describe 'Award Types index' do
  context 'when project' do
    let!(:project) { create :project }

    let(:visit_batches_page) do
      login(project.account)

      visit project_award_types_path(project)
    end

    context 'without mission' do
      before { visit_batches_page }

      it { expect(page).to have_current_path(project_award_types_path(project)) }
    end

    context 'with non-whitelabel mission' do
      before do
        project.update(mission: build(:mission))

        visit_batches_page
      end

      it { expect(page).to have_current_path(project_award_types_path(project)) }
    end

    context 'with whitelabel mission and project awards hidden' do
      let(:whitelabel_mission) { create :whitelabel_mission, whitelabel_domain: 'www.example.com' }

      before do
        project.update(mission: whitelabel_mission)

        visit_batches_page
      end

      it { expect(page).to have_current_path(projects_path) }
    end

    context 'with whitelabel mission and project awards visible' do
      before do
        project.mission.update(project_awards_visible: true)

        visit_batches_page
      end

      it { expect(page).to have_current_path(project_award_types_path(project)) }
    end
  end
end

require 'rails_helper'

describe 'Award Types index' do
  context 'when project' do
    before(:each) do
      login(project.account)

      visit project_award_types_path(project)
    end

    context 'without mission' do
      let(:project) { create :project }

      it { expect(page).to have_current_path(project_award_types_path(project)) }
    end

    context 'with non-whitelabel mission' do
      let(:project) { create :project, mission: build(:mission) }

      it { expect(page).to have_current_path(project_award_types_path(project)) }
    end

    context 'with whitelabel mission and project awards visible' do
      let(:whitelabel_mission) do
        create :whitelabel_mission, whitelabel_domain: 'www.example.com', project_awards_visible: true
      end

      let(:project) { create :project, mission: whitelabel_mission }

      it { expect(page).to have_current_path(project_award_types_path(project)) }
    end

    context 'with whitelabel mission and project awards hidden' do
      let(:whitelabel_mission) do
        create :whitelabel_mission, whitelabel_domain: 'www.example.com', project_awards_visible: false
      end

      let(:project) { create :project, mission: whitelabel_mission }

      it { expect(page).to have_current_path('/404.html') }
    end
  end
end

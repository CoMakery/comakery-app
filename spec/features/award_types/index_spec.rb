require 'rails_helper'

describe 'Award Types index', js: true do
  context 'when project mission' do
    let(:project) { create :project, mission: mission }

    before { login(project.account) }

    before { visit project_award_types_path(project) }

    context 'with visible awards' do
      let(:mission) { create :mission, project_awards_visible: true }

      it 'shows award types page' do
        expect(page).to have_current_path(project_award_types_path(project))
      end
    end

    context 'with hidden awards' do
      let(:mission) { create :mission, project_awards_visible: false }

      it 'shows not found page' do
        expect(page).to have_current_path('/404.html')
      end
    end
  end
end

require 'rails_helper'

describe 'Tasks Index' do
  let(:project) { create(:project) }

  before do
    project.update!(visibility: :public_listed)
    login project.account
    visit project_award_types_path(project)
  end

  subject { page }

  context 'with a non-lockup token' do
    it { is_expected.to have_link('tasks', href: project_award_types_path(project)) }
    it { is_expected.to have_text('Create a New Batch') }
  end

  context 'with a lockup token' do
    let(:project) { create(:project, token: create(:lockup_token)) }

    it { is_expected.not_to have_link('tasks', href: project_award_types_path(project)) }
    it { is_expected.not_to have_text('Create a New Batch') }
  end
end

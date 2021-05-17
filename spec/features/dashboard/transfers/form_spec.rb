require 'rails_helper'

describe 'transfer form on Transfers page' do
  let!(:project) { create(:project) }

  before do
    login project.account
    visit project_dashboard_transfers_path(project)
  end

  subject { page }

  describe 'lockup paramaters' do
    context 'with a lockup token' do
      let!(:project) { create(:project, token: create(:lockup_token)) }

      it { is_expected.to have_css("input[name='award[lockup_schedule_id]']") }
      it { is_expected.to have_css("input[name='award[commencement_date]']") }
    end

    context 'with other tokens' do
      it { is_expected.not_to have_css("input[name='award[lockup_schedule_id]']") }
      it { is_expected.not_to have_css("input[name='award[commencement_date]']") }
    end
  end
end

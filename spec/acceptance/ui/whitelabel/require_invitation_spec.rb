require 'rails_helper'

describe 'require invitation', type: :feature, js: false do
  context 'when whitelabel mission requires invitation' do
    let!(:whitelabel_mission) { create(:active_whitelabel_mission, require_invitation: true) }

    context 'and user is not signed in' do
      context 'when trying to sign up' do
        subject { visit new_account_path }

        it { is_expected.to have_current_path new_session_path }

        context 'and user has correct invite' do
          before do
            session[:invite_id] = FactoryBot.create(:invite).id
          end

          it { is_expected.not_to have_current_path new_session_path }
        end
      end

      context 'when trying to access projects page' do
        subject { visit projects_path }

        it { is_expected.to have_current_path new_session_path }
      end
    end

    context 'and user is signed in' do
      before do
        login FactoryBot.create(:account, managed_mission_id: whitelabel_mission)
      end

      context 'when trying to access projects page' do
        subject { visit projects_path }

        it { is_expected.not_to have_current_path new_session_path }
      end
    end
  end

  context 'when whitelabel mission does not require invitation' do
    let!(:whitelabel_mission) { create(:active_whitelabel_mission, require_invitation: false) }

    context 'and user is not signed in' do
      context 'when trying to sign up' do
        subject { visit new_account_path }

        it { is_expected.not_to have_current_path new_session_path }
      end

      context 'when trying to access projects page' do
        subject { visit projects_path }

        it { is_expected.not_to have_current_path new_session_path }
      end
    end
  end
end

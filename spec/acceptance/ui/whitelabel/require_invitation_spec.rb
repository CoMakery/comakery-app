require 'rails_helper'

describe 'require invitation', type: :feature, js: false do
  subject { page }

  context 'when whitelabel mission requires invitation' do
    let!(:whitelabel_mission) { create(:whitelabel_mission, whitelabel_domain: 'www.example.com', require_invitation: true) }

    context 'and user is not signed in' do
      context 'when trying to sign up' do
        context 'and user doesnt have correct invite' do
          before do
            visit new_account_path
          end

          it { is_expected.to have_current_path new_session_path }
        end

        context 'and user has correct invite' do
          before do
            page.set_rack_session(invite_id: FactoryBot.create(:invite).id)
            visit new_account_path(invited: true)
          end

          it { is_expected.to have_current_path new_account_path(invited: true) }
        end
      end

      context 'when trying to access projects page' do
        before do
          visit projects_path
        end

        it { is_expected.to have_current_path new_session_path }
      end

      context 'when trying to follow an invite link' do
        before do
          visit invite_path(FactoryBot.create(:invite).token)
        end

        it { is_expected.to have_current_path new_account_path(invited: true) }
      end

      context 'when trying to unsubscribe' do
        before do
          visit unsubscription_path
        end

        it { is_expected.to have_current_path unsubscription_path }
      end

      context 'when trying to reset password' do
        before do
          visit new_password_reset_path
        end

        it { is_expected.to have_current_path new_password_reset_path }
      end
    end

    context 'and user is signed in' do
      before do
        login FactoryBot.create(:account, managed_mission_id: whitelabel_mission)
      end

      context 'when trying to access projects page' do
        before do
          visit projects_path
        end

        it { is_expected.to have_current_path projects_path }
      end
    end
  end

  context 'when whitelabel mission does not require invitation' do
    let!(:whitelabel_mission) { create(:whitelabel_mission, whitelabel_domain: 'www.example.com', require_invitation: false) }

    context 'and user is not signed in' do
      context 'when trying to sign up' do
        before do
          visit new_account_path
        end

        it { is_expected.to have_current_path new_account_path }
      end

      context 'when trying to access projects page' do
        before do
          visit projects_path
        end

        it { is_expected.to have_current_path projects_path }
      end
    end
  end
end

require 'rails_helper'

describe 'account creation', js: true do
  context 'when following invite link' do
    let(:invite) { FactoryBot.create :invite, :for_admin, force_email: true }
    let(:project) { invite.invitable.project }

    before do
      visit invite_path(invite.token)
    end

    subject { page }

    it { is_expected.to have_current_path(new_account_path) }

    context 'and creating the account' do
      before do
        within('.new_account') do
          fill_in 'account[password]', with: Faker::Internet.password
          check 'account_agreed_to_user_agreement'
          click_button 'Create Your Account'
        end
      end

      it { is_expected.to have_current_path(build_profile_accounts_path) }

      context 'and completing building the profile' do
        before do
          within('.edit_account') do
            fill_in 'account[first_name]', with: Faker::Name.first_name
            fill_in 'account[last_name]', with: Faker::Name.last_name
            fill_in 'account[date_of_birth]', with: Faker::Date.birthday.strftime('%m/%d/%Y')
            select 'United States of America', from: 'account[country]'
            click_button 'Get Started'
          end
        end

        it { is_expected.to have_current_path(project_dashboard_accounts_path(project)) }
      end
    end
  end
end

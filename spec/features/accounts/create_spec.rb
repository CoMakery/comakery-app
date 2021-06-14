require 'rails_helper'

describe 'Create account', js: true do
  context 'when a user joins to platform via a project invitation' do
    let(:project) { create(:project) }

    let(:invite) { FactoryBot.create(:invite, invitable: project, role: 'admin') }

    let(:account) { Account.last }

    let(:create_account) do
      within('.new_account') do
        fill_in 'account[email]', with: invite.email

        fill_in 'account[password]', with: Faker::Internet.password

        check 'account_agreed_to_user_agreement'

        click_button 'Create Your Account'
      end
    end

    before { visit new_account_path(token: invite.token) }

    before { create_account }

    it { expect(page).to have_current_path(build_profile_accounts_path) }

    it { expect(account.confirmed?).to be(true) }

    context 'and build profile' do
      before do
        within('.edit_account') do
          fill_in 'account[first_name]', with: Faker::Name.first_name

          fill_in 'account[last_name]', with: Faker::Name.last_name

          fill_in 'account[date_of_birth]', with: Faker::Date.birthday.strftime('%m/%d/%Y')

          select 'United States of America', from: 'account[country]'

          click_button 'Get Started'
        end
      end

      it { expect(page).to have_current_path project_path(project) }

      it { expect(page).to have_content("You have successfully joined the project with the #{invite.role}") }
    end
  end
end

require 'rails_helper'

describe 'Invite new admin user', js: true do
  let(:admin) { create(:account) }

  let(:invite) do
    FactoryBot.create(:invite, :for_admin, force_email: true)
  end

  let(:project) { invite.invitable.project }

  before do
    project.project_admins << admin
  end

  context 'admin invites new admin user' do
    let(:open_form) do
      find('[data-target="#invite-person"]').click
    end

    let(:invite_new_admin) do
      within('#invite-person form') do
        fill_in 'email', with: invite.email

        select 'Admin', from: 'role'

        click_button 'Save'
      end
    end

    before do
      login admin
      visit project_dashboard_accounts_path(project)
      open_form
      invite_new_admin
    end

    it 'shows invite sending message success' do
      expect(find('.flash-message-container')).to have_content('Invite successfully sent')
    end
  end

  context 'email is correct and user can continue registration' do
    subject(:result) do
      UserMailer.send_invite_to_platform(invite.invitable.reload).deliver_now
    end

    it 'checks if email subject is correct' do
      expect(result.subject).to eq "Invitation to #{project.title} on CoMakery"
    end

    it 'checks if email text is correct' do
      expect(result.body.encoded).to match(%(
        You have been invited to have the role 'Admin' 
        for the project #{project.title} on CoMakery.
      ).squish)

      expect(result.body.encoded).to match(%(
        To accept the invitation follow this link
      ).squish)
    end
  end

  context 'user can continue registration' do
    let(:account) { Account.last }

    let(:create_account) do
      within('.new_account') do
        fill_in 'account[email]', with: invite.email

        fill_in 'account[password]', with: Faker::Internet.password

        check 'account_agreed_to_user_agreement'

        click_button 'Create Your Account'
      end
    end

    before do
      visit invite_path(invite.token)
      create_account
    end

    it 'checks cotinue building profile path' do
      expect(page).to have_current_path(build_profile_accounts_path)
    end

    it 'checks if account is confirmed' do
      expect(account.confirmed?).to be(true)
    end

    context 'user edits profile and see the project at the finish' do
      before do
        within('.edit_account') do
          fill_in 'account[first_name]', with: Faker::Name.first_name

          fill_in 'account[last_name]', with: Faker::Name.last_name

          fill_in 'account[date_of_birth]', with: Faker::Date.birthday
                                                             .strftime('%m/%d/%Y')

          select 'United States of America', from: 'account[country]'

          click_button 'Get Started'
        end
      end

      it 'checks forwarding to the project admin was invited to' do
        expect(page).to have_current_path project_dashboard_accounts_path(project)
      end
    end
  end
end

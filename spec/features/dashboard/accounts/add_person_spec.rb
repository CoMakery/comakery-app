require 'rails_helper'

describe 'Add person', js: true do
  let(:account) { create(:account) }

  let(:admin) { create(:account) }

  let(:project) { create(:project) }

  before { project.project_admins << admin }

  before { login(admin) }

  before { visit project_dashboard_accounts_path(project) }

  before(:each) do
    open_modal

    add_person
  end

  context 'when send an invitation to an invalid email' do
    let(:open_modal) { find('[data-target="#invite-person"]').click }

    let(:add_person) do
      within('#invite-person form') do
        fill_in 'email', with: 'invalid'

        select 'Project Member', from: 'role'

        click_button 'Save'
      end
    end

    it 'assigns account with role to project' do
      expect(find('#invite-person ul.errors').text).to eq('Email is invalid')
    end
  end

  context 'when assign a role to an existing account' do
    let(:open_modal) { find('[data-target="#invite-person"]').click }

    let(:add_person) do
      within('#invite-person form') do
        fill_in 'email', with: account.email

        select 'Project Member', from: 'role'

        click_button 'Save'
      end
    end

    it 'assigns account with role to project' do
      expect(find('.flash-message-container')).to have_content('Invite successfully sent')

      expect(page).to have_css("#project_#{project.id}_account_#{account.id}", count: 1, wait: 60)
    end
  end

  context 'when assign a role to an unregistered user' do
    let(:open_modal) { find('[data-target="#invite-person"]').click }

    let(:add_person) do
      within('#invite-person form') do
        fill_in 'email', with: 'example@gmail.com'

        select 'Project Member', from: 'role'

        click_button 'Save'
      end
    end

    it 'sends invite to join a platform' do
      expect(find('.flash-message-container')).to have_content('Invite successfully sent')
    end
  end
end

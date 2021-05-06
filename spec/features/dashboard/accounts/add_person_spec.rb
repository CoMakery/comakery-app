require 'rails_helper'

describe 'Add person', js: true do
  let(:account) { create(:account, comakery_admin: true) }
  let(:owner) { create(:account, comakery_admin: true) }
  let(:project) { create(:project, account: owner) }

  scenario 'grants access to registered account' do
    login(owner)
    visit project_dashboard_accounts_path(project)

    find('[data-target="#invite-person"]').click

    within('#invite-person form') do
      fill_in 'email', with: account.email

      select 'Interested', from: 'role'

      click_button 'Save'
    end

    expect(find('.flash-message-container')).to have_content('Invite successfully sent')
  end

  scenario 'fails with unregistered account' do
    login(owner)
    visit project_dashboard_accounts_path(project)

    find('a[data-target="#invite-person"]').click

    within('#invite-person form') do
      fill_in 'email', with: ''

      select 'Interested', from: 'role'

      click_button 'Save'
    end

    expect(find('#invite-person ul.errors')).to have_content('The user must have signed up to add them')
  end
end

require 'rails_helper'

describe 'Add person', js: true do
  let(:account) { create(:account) }

  let(:admin) { create(:account) }

  let(:project) { create(:project) }

  before { project.project_admins << admin }

  before { login(admin) }

  before { visit project_dashboard_accounts_path(project) }

  scenario 'grants access to registered account' do
    find('[data-target="#invite-person"]').click

    within('#invite-person form') do
      fill_in 'email', with: account.email

      select 'Project Member', from: 'role'

      click_button 'Save'
    end

    expect(find('.flash-message-container')).to have_content('Invite successfully sent')

    expect(page).to have_css("#project_#{project.id}_account_#{account.id}", count: 1)
  end

  scenario 'fails with unregistered account' do
    find('a[data-target="#invite-person"]').click

    within('#invite-person form') do
      fill_in 'email', with: ''

      select 'Project Member', from: 'role'

      click_button 'Save'
    end

    expect(find('#invite-person ul.errors').text).to eq('The User Must Have Signed Up To Add Them')
  end
end

require 'rails_helper'

describe 'Account settings', js: true do
  let(:project) { create(:project) }

  let(:open_settings) { first('[data-id="settings"]').click }

  let(:dropdown_menu) { first('.dropdown-menu') }

  context 'when logged in as admin' do
    let(:admin) { create(:account) }

    before do
      project.project_admins << admin

      login(admin)

      visit project_dashboard_accounts_path(project)
    end

    it { expect(page).to have_css('#account_settings', count: 2) }

    before { open_settings }

    it 'shows active link to change permissions' do
      expect(dropdown_menu).not_to have_css('.disabled')
    end
  end

  context 'when logged in as read only admin' do
    let(:observer) { create(:account) }

    before do
      project.project_observers << observer

      login(observer)

      visit project_dashboard_accounts_path(project)
    end

    it { expect(page).to have_css('#account_settings', count: 2) }

    before { open_settings }

    it 'shows disabled link to change permissions' do
      expect(dropdown_menu).to have_css('.disabled')
    end
  end
end

require 'rails_helper'

describe 'Add Admin', js: true do
  let(:owner) { create :account }
  let(:project) { create :project, account: owner }

  context 'regular user' do
    let(:admin) { create :account, email: 'test@test.com', first_name: 'test', last_name: 'test' }

    scenario 'grants access with regular user' do
      login(owner)
      visit project_dashboard_accesses_path(project)

      within('.form-with-submit-button') do
        fill_in 'email', with: admin.email

        click_button 'commit'
      end

      expect(page).to have_content 'test test added as a project admin'
    end

    scenario 'fails with existing regular user' do
      login(owner)

      project.admins << admin
      project.reload

      visit project_dashboard_accesses_path(project)

      within('.form-with-submit-button') do
        fill_in 'email', with: admin.email

        click_button 'commit'
      end

      expect(page).to have_content 'test test is already a project admin'
    end
  end

  # this will fail unless html_escape in layout
  context 'malicious user' do
    let(:admin) { create :account, email: 'test@test.com', first_name: '"><SCRIPT>alert(\'x\');</SCRIPT> ', last_name: 'test' }

    scenario 'grants access with regular user' do
      login(owner)
      visit project_dashboard_accesses_path(project)

      within('.form-with-submit-button') do
        fill_in 'email', with: admin.email

        click_button 'commit'
      end

      expect(page).to have_content '"><SCRIPT>alert(\'x\');</SCRIPT> test added as a project admin'
    end

    scenario 'fails with existing regular user' do
      login(owner)

      project.admins << admin
      project.reload

      visit project_dashboard_accesses_path(project)

      within('.form-with-submit-button') do
        fill_in 'email', with: admin.email

        click_button 'commit'
      end

      expect(page).to have_content '"><SCRIPT>alert(\'x\');</SCRIPT> test is already a project admin'
    end
  end
end

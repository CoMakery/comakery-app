require 'rails_helper'

describe 'viewing metrics' do
  let!(:admin_role) { Role.find_or_create_by!(key: Role::ADMIN_ROLE_KEY) { |role| role.name = 'Admin' } }
  let!(:account) { create(:account).tap { |a| a.roles << Role.admin } }

  before { login(account) }

  specify do
    visit '/admin/metrics'

    expect(page).to have_content 'Metrics'
    expect(page).to have_content 'Sign-ups per day'
    expect(page).to have_content 'Sign-ups per week'
  end
end

require 'rails_helper'
require Rails.root.join('db/data_migrations/20210429220841_set_admin_role_for_accounts')

describe SetAdminRoleForAccounts do
  subject { described_class.new.up }

  it 'update admins role to admin and keeps regular user' do
    project = create(:project, account: create(:account))
    admin_user = create(:account)
    regular_user = create(:account)

    project.admins << admin_user
    create(:project_role, account: admin_user, project: project)
    create(:project_role, account: regular_user, project: project)

    expect(admin_user.project_roles.first.role).to eq 'interested'
    expect(regular_user.project_roles.first.role).to eq 'interested'

    expect(project.project_roles.count).to eq 3 # +owner

    subject
    project.reload
    admin_user.reload
    regular_user.reload

    #did not change
    expect(project.project_roles.count).to eq 3
    expect(regular_user.project_roles.first.role).to eq 'interested'

    #changed
    expect(admin_user.project_roles.first.role).to eq 'admin'
  end
end

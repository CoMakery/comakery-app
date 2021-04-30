require 'rails_helper'
require Rails.root.join('db/data_migrations/20210426121452_fill_roles_with_interests')

describe FillRolesWithInterests do
  subject { described_class.new.up }

  it 'update admins and owner role to admin' do
    project = create(:project, account: create(:account))
    admin_user = create(:account)
    create(:interest, account: admin_user, project: project, protocol: nil, specialty: nil)
    create(:interest, account: admin_user, project: project, protocol: 'test', specialty: nil)
    create(:interest, account: create(:account), project: project, protocol: nil, specialty: nil)

    expect(project.interests.count).to eq 4

    subject
    project.reload

    # didn't change
    expect(project.interests.count).to eq 4
    expect(project.project_roles.count).to eq 3
    # expect(interested.interests.first.role).to eq 'interested'

    # changed role to admin
    # expect(owner.interests.first.role).to eq 'admin'
    # expect(admin.interests.first.role).to eq 'admin'
  end
end

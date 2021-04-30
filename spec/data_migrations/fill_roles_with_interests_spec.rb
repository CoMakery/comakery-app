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
    # owner become admin after create
    # so it's equivalent to no project roles present(after migrate) and inserting
    # owner role from interest
    #
    expect(project.project_roles.count).to eq 1

    subject
    project.reload

    expect(project.interests.count).to eq 4
    expect(project.project_roles.count).to eq 4
  end
end

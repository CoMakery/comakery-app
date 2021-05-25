require 'rails_helper'
require Rails.root.join('db/data_migrations/20210426121452_fill_roles_with_interests')

describe FillRolesWithInterests do
  subject { described_class.new.up }

  it 'sets project roles from interests' do
    project = create(:project, account: create(:account))
    admin_user = create(:account)
    create(:interest, account: admin_user, project: project, protocol: nil, specialty: nil)
    create(:interest, account: admin_user, project: project, protocol: 'test', specialty: nil)
    create(:interest, account: create(:account), project: project, protocol: nil, specialty: nil)

    # interests will have owner, 2 admins and interested
    #
    #
    expect(project.interests.count).to eq 3
    # owner become admin after create
    # so it's equivalent to no project roles present(after migrate) and inserting
    # owner role from interest
    #
    expect(project.project_roles.count).to eq 1

    subject
    project.reload

    # interests won't change
    expect(project.interests.count).to eq 3

    # because interests have duplicates
    expect(project.project_roles.count).to eq 3
  end
end

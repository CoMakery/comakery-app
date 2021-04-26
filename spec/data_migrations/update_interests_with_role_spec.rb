require 'rails_helper'
require Rails.root.join('db/data_migrations/20210426121452_update_interests_with_role')

describe UpdateInterestsWithRole do
  subject { described_class.new.up }

  it 'update admins and owner role to admin' do
    owner = create(:account)
    admin = create(:account)
    interested = create(:account)
    project = create(:project, account: owner)
    project.interested << [admin, interested]
    project.admins << admin

    expect(project.interested).to contain_exactly(owner, admin, interested)
    expect(project.admins).to contain_exactly(admin)
    expect(owner.interests.first.role).to eq 'member'
    expect(admin.interests.first.role).to eq 'member'
    expect(interested.interests.first.role).to eq 'member'

    subject
    project.reload
    admin.reload
    owner.reload
    interested.reload

    # didn't change
    expect(project.interested).to contain_exactly(owner, admin, interested)
    expect(project.admins).to contain_exactly(admin)
    expect(interested.interests.first.role).to eq 'member'

    # changed role to admin
    expect(owner.interests.first.role).to eq 'admin'
    expect(admin.interests.first.role).to eq 'admin'
  end
end

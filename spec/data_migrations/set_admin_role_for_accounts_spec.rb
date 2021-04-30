require 'rails_helper'
require Rails.root.join('db/data_migrations/20210429220841_set_admin_role_for_accounts')

describe SetAdminRoleForAccounts do
  subject { described_class.new.up }

  it 'update admins and owner role to admin' do

  end
end

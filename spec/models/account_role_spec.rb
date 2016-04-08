# == Schema Information
#
# Table name: account_roles
#
#  account_id :integer          not null
#  created_at :datetime
#  id         :integer          not null, primary key
#  role_id    :integer          not null
#  updated_at :datetime
#
# Indexes
#
#  index_account_roles_on_account_id_and_role_id  (account_id,role_id) UNIQUE
#

require 'rails_helper'

describe AccountRole do
  context 'invalid' do
    let(:account) { create :account }
    let(:role) { create :role }
    subject(:account_role) { create :account_role, account, role }

    specify { expect_invalid_value(:account, nil) }
    specify { expect_invalid_value(:role, nil) }
  end
end

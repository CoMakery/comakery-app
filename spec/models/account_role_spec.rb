require 'rails_helper'

describe AccountRole do
  context 'invalid' do
    subject(:account_role) { create :account_role, account, role }

    let(:account) { create :account }
    let(:role) { create :role }

    specify { expect_invalid_value(:account, nil) }
    specify { expect_invalid_value(:role, nil) }
  end
end

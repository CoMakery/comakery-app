require 'rails_helper'

RSpec.describe ApiOreIdWalletRecovery, type: :model do
  subject { ApiOreIdWalletRecovery.new(api_request_log: create(:api_request_log)) }

  it { is_expected.to belong_to(:api_request_log) }
  it { is_expected.to validate_uniqueness_of(:api_request_log_id) }

  context 'with an expired api_request_log' do
    subject { ApiOreIdWalletRecovery.create(api_request_log: create(:api_request_log, created_at: 1.year.ago)) }

    it { is_expected.not_to be_persisted }
  end
end

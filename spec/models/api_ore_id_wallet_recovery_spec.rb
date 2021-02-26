require 'rails_helper'

RSpec.describe ApiOreIdWalletRecovery, type: :model do
  subject { ApiOreIdWalletRecovery.new(api_request_log: create(:api_request_log)) }

  it { is_expected.to belong_to(:api_request_log) }
  it { is_expected.to validate_uniqueness_of(:api_request_log_id) }
end

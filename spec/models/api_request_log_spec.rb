require 'rails_helper'

RSpec.describe ApiRequestLog, type: :model do
  it { is_expected.to validate_presence_of(:ip) }
  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_presence_of(:signature) }
  it { is_expected.to have_one(:api_ore_id_wallet_recovery) }

  it 'validate uniqueness of signature' do
    create(:api_request_log)
    new_request_log = build(:api_request_log)
    expect(new_request_log.valid?).to be false
    expect(new_request_log.errors.messages).to eq signature: ['has already been taken']
  end
end

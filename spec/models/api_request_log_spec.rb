require 'rails_helper'

RSpec.describe ApiRequestLog, type: :model do
  it { is_expected.to validate_presence_of(:ip) }
  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_presence_of(:signature) }
  it 'validate uniqueness of signature' do
    ApiRequestLog.create(signature: 'test_signature', ip: IPAddr.new('0.0.0.0'), body: { test: :test })
    new_request_log = ApiRequestLog.new(signature: 'test_signature', ip: IPAddr.new('0.0.0.0'), body: { test: :test })
    expect(new_request_log.valid?).to be false
    expect(new_request_log.errors.messages).to eq signature: ['has already been taken']
  end
end

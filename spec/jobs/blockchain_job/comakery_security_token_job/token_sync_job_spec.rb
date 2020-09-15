require 'rails_helper'

RSpec.describe BlockchainJob::ComakerySecurityTokenJob::TokenSyncJob, type: :job do
  let!(:token) { stub_blockchain_sync && create(:token, _token_type: :comakery_security_token, _blockchain: 'ethereum_ropsten', contract_address: '0x0000000000000000000000000000000000000000') }
  let!(:invalid_token) { stub_blockchain_sync && create(:token) }
  let!(:account) { create(:account, ethereum_wallet: '0x0000000000000000000000000000000000000000') }
  let!(:project) { create(:project, token: token, account: account) }

  it 'updates token record' do
    described_class.perform_now(token)
    expect(token.reload.synced_at).not_to be_nil
  end

  it 'raises an error if token is not comakery type' do
    expect { described_class.perform_now(invalid_token) }.to raise_error(RuntimeError, 'Token is not Comakery Type')
  end

  it 'schedules sync jobs for belonging account records' do
    ActiveJob::Base.queue_adapter = :test
    expect { described_class.perform_now(token) }.to have_enqueued_job(BlockchainJob::ComakerySecurityTokenJob::AccountSyncJob)
  end
end

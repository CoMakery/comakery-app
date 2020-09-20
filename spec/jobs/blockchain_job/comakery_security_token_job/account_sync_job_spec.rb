require 'rails_helper'

RSpec.describe BlockchainJob::ComakerySecurityTokenJob::AccountSyncJob, type: :job, vcr: true do
  let!(:account) { create(:account, ethereum_wallet: '0x0000000000000000000000000000000000000000') }
  let!(:token) { stub_blockchain_sync && create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: 'ethereum_ropsten') }
  let!(:record) { create(:account_token_record, account: account, token: token) }
  let!(:invalid_record) { create(:account_token_record, account: create(:account, ethereum_wallet: nil), token: token) }

  it 'updates account_token_record' do
    described_class.perform_now(record)
    expect(record.reload.synced_at).not_to be_nil
  end

  it 'returns if account doesnt have ethereum wallet' do
    described_class.perform_now(invalid_record)
    expect(invalid_record.reload.synced_at).to be_nil
  end
end

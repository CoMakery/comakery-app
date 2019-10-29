require 'rails_helper'

RSpec.describe Blockchain::ComakerySecurityToken::AccountSyncJob, type: :job do
  let!(:account) { create(:account, ethereum_wallet: '0x0000000000000000000000000000000000000000') }
  let!(:token) { stub_blockchain_sync && create(:token, coin_type: :comakery, ethereum_network: 'main', ethereum_contract_address: '0x0000000000000000000000000000000000000000') }
  let!(:record) { create(:account_token_record, account: account, token: token) }
  let!(:invalid_record) { create(:account_token_record, account: create(:account), token: token) }

  it 'updates account_token_record' do
    described_class.perform_now(record)
    expect(record.reload.synced_at).not_to be_nil
  end

  it 'raises an error if account doesnt have ethereum wallet' do
    expect { described_class.perform_now(invalid_record) }.to raise_error(RuntimeError, 'Wallet is not present')
  end
end

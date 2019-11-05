require 'rails_helper'

RSpec.describe Blockchain::SyncJob, type: :job do
  let!(:comakery_token) { stub_blockchain_sync && create(:token, coin_type: :comakery, ethereum_network: 'main', ethereum_contract_address: '0x0000000000000000000000000000000000000000') }

  it 'schedules sync jobs for Comakery tokens' do
    ActiveJob::Base.queue_adapter = :test
    expect { described_class.perform_now }.to have_enqueued_job(Blockchain::ComakerySecurityToken::TokenSyncJob)
  end
end

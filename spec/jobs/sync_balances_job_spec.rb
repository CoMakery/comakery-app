require 'rails_helper'

RSpec.describe SyncBalancesJob, type: :job do
  let!(:balances) do
    [
      create(:balance, created_at: 11.seconds.ago, updated_at: 11.seconds.ago),
      create(:balance, created_at: 11.seconds.ago, updated_at: 11.seconds.ago),
      create(:balance, created_at: 1.second.ago, updated_at: 1.second.ago)
    ]
  end
  subject { described_class.perform_now }

  it 'schedule sync balance jobs for required balances' do
    expect(SyncBalanceJob).to receive(:perform_later).twice

    is_expected.to be true
  end
end

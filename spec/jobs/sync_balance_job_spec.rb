require 'rails_helper'

RSpec.describe SyncBalanceJob, type: :job do
  let(:token_with_balance_support) { create(:comakery_token) }
  let(:wallet) { create(:wallet, address: build(:ethereum_address_1), _blockchain: token_with_balance_support._blockchain) }

  let(:balance) { create(:balance, wallet: wallet, token: token_with_balance_support) }
  subject { described_class.perform_now(balance) }

  before do
    # Freeze time, replace me with Timecop.freeze
    allow_any_instance_of(ActiveSupport::TimeZone).to receive(:now).and_return(Time.zone.now)
  end

  it 'succesfully update a value' do
    allow_any_instance_of(Balance).to receive(:blockchain_balance_base_unit_value).and_return(999)
    is_expected.to be true
    expect(balance.reload.base_unit_value).to eq 999
  end

  context 'do not update a value' do
    let(:balance) { create(:balance, wallet: wallet, token: token_with_balance_support, created_at: 1.day.ago, updated_at: Time.zone.now, base_unit_value: 10) }

    it 'when it was updated recently' do
      allow_any_instance_of(Balance).to receive(:blockchain_balance_base_unit_value).and_return(999)
      is_expected.to be nil
      expect(balance.reload.base_unit_value).to eq 10
    end
  end
end

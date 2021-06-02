require 'rails_helper'

RSpec.describe SyncBalanceJob, type: :job do
  subject(:perform) { described_class.perform_now(balance) }

  let(:now) { Time.zone.local(2021, 6, 1, 15) }
  let(:token_with_balance_support) { create(:comakery_token) }
  let(:wallet) do
    create :wallet,
           address: build(:ethereum_address_1), _blockchain: token_with_balance_support._blockchain
  end
  let(:balance) do
    create(:balance, wallet: wallet, token: token_with_balance_support, base_unit_value: 10)
  end

  before do
    allow(balance).to receive(:blockchain_balance_base_unit_value).and_return(999)
    allow(Sentry).to receive(:capture_exception)
    Timecop.freeze(now)
  end

  after { Timecop.return }

  context 'when balance was update long time ago' do
    it 'should update base unit value' do
      perform
      expect(balance.reload.base_unit_value).to eq 999
    end

    it 'should not report an exception' do
      perform
      expect(Sentry).not_to have_received(:capture_exception)
    end
  end

  context 'when balance was updated recently' do
    let(:balance) do
      create :balance, wallet: wallet, token: token_with_balance_support, base_unit_value: 10, created_at: 1.day.ago(now), updated_at: now
    end

    it 'should not update base unit value' do
      perform
      expect(balance.reload.base_unit_value).to eq 10
    end

    it 'should not report an exception' do
      perform
      expect(Sentry).not_to have_received(:capture_exception)
    end
  end

  context 'when standard error is raised' do
    before { allow(balance).to receive(:sync_with_blockchain!).and_raise(StandardError) }

    it 'should not update base unit value' do
      perform
      expect(balance.reload.base_unit_value).to eq 10
    end

    it 'should report an exception' do
      perform
      expect(Sentry).to have_received(:capture_exception).with(StandardError)
    end
  end
end

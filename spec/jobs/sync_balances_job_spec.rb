require 'rails_helper'

RSpec.describe SyncBalancesJob, type: :job do
  let(:token_with_balance_support) { create(:comakery_token) }
  let(:wallet) { create(:wallet, address: build(:ethereum_address_1), _blockchain: token_with_balance_support._blockchain) }

  subject { described_class.perform_now }

  context 'when balance has not been updated after creation' do
    let!(:balance) { create(:balance, wallet: wallet, token: token_with_balance_support) }

    it 'schedules sync balance job' do
      expect(SyncBalanceJob).to receive(:perform_later)

      subject
    end
  end

  context 'when balance has been updated long time ago' do
    let!(:balance) { create(:balance, wallet: wallet, token: token_with_balance_support, updated_at: 1.year.ago) }

    it 'schedules sync balance job' do
      expect(SyncBalanceJob).to receive(:perform_later)

      subject
    end
  end

  context 'when balance has been just updated' do
    let!(:balance) { create(:balance, wallet: wallet, token: token_with_balance_support, updated_at: 1.year.from_now) }

    it 'doesnt schedule sync balance job' do
      expect(SyncBalanceJob).not_to receive(:perform_later)

      subject
    end
  end
end

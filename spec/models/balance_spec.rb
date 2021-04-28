require 'rails_helper'

describe Balance, type: :model do
  subject { build(:balance) }
  it { is_expected.to belong_to(:wallet) }
  it { is_expected.to belong_to(:token) }
  it { is_expected.to validate_presence_of(:base_unit_value) }
  it { is_expected.to validate_numericality_of(:base_unit_value).only_integer.is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_uniqueness_of(:wallet_id).scoped_to(:token_id) }
  it { is_expected.to validate_inclusion_of(:token_id).in_array(subject.wallet.tokens_of_the_blockchain.pluck(:id)) }
  let(:balance) { create(:balance) }

  describe '#ready_for_balance_update?' do
    context 'when token has balance support' do
      let(:token_with_balance_support) { create(:comakery_token) }
      let(:wallet) { create(:wallet, address: build(:ethereum_address_1), _blockchain: token_with_balance_support._blockchain) }

      context 'when balance has not been updated after creation' do
        let(:balance) { create(:balance, wallet: wallet, token: token_with_balance_support) }
        subject { balance.ready_for_balance_update? }

        it { is_expected.to be_truthy }
        specify { expect(described_class.ready_for_balance_update).to include(balance) }
      end

      context 'when balance has been updated long time ago' do
        let(:balance) { create(:balance, wallet: wallet, token: token_with_balance_support, updated_at: 1.year.ago) }
        subject { balance.ready_for_balance_update? }

        it { is_expected.to be_truthy }
        specify { expect(described_class.ready_for_balance_update).to include(balance) }
      end

      context 'when balance has been just updated' do
        let(:balance) { create(:balance, wallet: wallet, token: token_with_balance_support, updated_at: 1.year.from_now) }
        subject { balance.ready_for_balance_update? }

        it { is_expected.to be_falsey }
        specify { expect(described_class.ready_for_balance_update).not_to include(balance) }
      end
    end

    context 'when token has no balance support' do
      let(:token_without_balance_support) { create(:token, _token_type: :btc) }
      let(:wallet) { create(:wallet, _blockchain: token_without_balance_support._blockchain) }

      context 'when balance has not been updated after creation' do
        let(:balance) { create(:balance, wallet: wallet, token: token_without_balance_support) }
        subject { balance.ready_for_balance_update? }

        it { is_expected.to be_falsey }
        specify { expect(described_class.ready_for_balance_update).not_to include(balance) }
      end
    end
  end

  describe '#value' do
    subject { balance.value }

    specify do
      expect(balance.token).to receive(:from_base_unit).with(balance.base_unit_value).and_return(999)

      is_expected.to eq 999
    end
  end

  describe '#blockchain_balance_base_unit_value' do
    subject { balance.blockchain_balance_base_unit_value }

    specify do
      expect(balance.token).to receive(:blockchain_balance).with(balance.wallet.address).and_return(999)

      is_expected.to eq 999
    end
  end

  describe '#sync_with_blockchain!' do
    subject { balance.sync_with_blockchain! }

    specify do
      expect(balance.token).to receive(:blockchain_balance).with(balance.wallet.address).and_return(999)

      expect(balance.base_unit_value).to eq 0
      is_expected.to be true
      expect(balance.reload.base_unit_value).to eq 999
    end
  end

  describe '#sync_with_blockchain_later' do
    subject { balance.sync_with_blockchain_later }

    it 'schedules balances sync' do
      expect(SyncBalanceJob).to receive(:set).and_call_original
      expect_any_instance_of(ActiveJob::ConfiguredJob).to receive(:perform_later)
      subject
    end
  end
end
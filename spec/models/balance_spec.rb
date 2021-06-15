require 'rails_helper'

describe Balance, type: :model do
  subject { build(:balance) }
  it { is_expected.to belong_to(:wallet) }
  it { is_expected.to belong_to(:token) }
  it { is_expected.to validate_presence_of(:base_unit_value) }
  it { is_expected.to validate_presence_of(:base_unit_locked_value) }
  it { is_expected.to validate_presence_of(:base_unit_unlocked_value) }
  it { is_expected.to validate_numericality_of(:base_unit_value).only_integer.is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:base_unit_locked_value).only_integer.is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:base_unit_unlocked_value).only_integer.is_greater_than_or_equal_to(0) }
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

  describe '#locked_value' do
    subject { balance.locked_value }

    specify do
      expect(balance.token).to receive(:from_base_unit).with(balance.base_unit_locked_value).and_return(999)

      is_expected.to eq 999
    end
  end

  describe '#unlocked_value' do
    subject { balance.unlocked_value }

    specify do
      expect(balance.token).to receive(:from_base_unit).with(balance.base_unit_unlocked_value).and_return(999)

      is_expected.to eq 999
    end
  end

  describe '#lockup_schedule_ids' do
    let!(:token) { create(:lockup_token) }
    let!(:project) { create(:project, token: token) }
    let!(:award_type) { create(:award_type, project: project) }
    let!(:wallet) { create(:wallet, address: build(:ethereum_address_1), _blockchain: 'ethereum_rinkeby') }
    let!(:balance) { create(:balance, wallet: wallet, token: token) }
    let!(:transfer) { create(:award, account: wallet.account, recipient_wallet: wallet, lockup_schedule_id: 1, commencement_date: Time.current, status: :accepted, award_type: award_type) }

    subject { balance.lockup_schedule_ids }

    context 'for a transfer with the same token' do
      context 'in paid status' do
        before do
          transfer.paid!
        end

        it { is_expected.to include(transfer.lockup_schedule_id) }
      end

      context 'in accepted status' do
        before do
          transfer.accepted!
        end

        it { is_expected.not_to include(transfer.lockup_schedule_id) }
      end

      context 'in cancelled status' do
        before do
          transfer.cancelled!
        end

        it { is_expected.not_to include(transfer.lockup_schedule_id) }
      end
    end

    context 'for a transfer with a different token' do
      let!(:balance) { create(:balance, wallet: wallet, token: create(:lockup_token)) }

      it { is_expected.not_to include(transfer.lockup_schedule_id) }
    end
  end

  describe '#blockchain_balance_base_unit_value' do
    subject { balance.blockchain_balance_base_unit_value }

    specify do
      expect(balance.token).to receive(:blockchain_balance).with(balance.wallet.address).and_return(999)

      is_expected.to eq 999
    end
  end

  describe '#blockchain_balance_base_unit_locked_value' do
    subject { balance.blockchain_balance_base_unit_locked_value }

    context 'with a lockup token' do
      let(:balance) { create(:balance, token: create(:lockup_token), wallet: create(:eth_wallet, _blockchain: :ethereum_rinkeby)) }

      specify do
        expect(balance.token).to receive(:blockchain_locked_balance).with(balance.wallet.address).and_return(999)

        is_expected.to eq 999
      end
    end

    context 'with other tokens' do
      specify do
        expect(balance.token).not_to receive(:blockchain_locked_balance).with(balance.wallet.address)

        is_expected.to eq 0
      end
    end
  end

  describe '#blockchain_balance_base_unit_unlocked_value' do
    subject { balance.blockchain_balance_base_unit_unlocked_value }

    context 'with a lockup token' do
      let(:balance) { create(:balance, token: create(:lockup_token), wallet: create(:eth_wallet, _blockchain: :ethereum_rinkeby)) }

      specify do
        expect(balance.token).to receive(:blockchain_unlocked_balance).with(balance.wallet.address).and_return(999)

        is_expected.to eq 999
      end
    end

    context 'with other tokens' do
      specify do
        expect(balance.token).not_to receive(:blockchain_unlocked_balance).with(balance.wallet.address)
        expect(balance.token).to receive(:blockchain_balance).with(balance.wallet.address).and_return(999)

        is_expected.to eq 999
      end
    end
  end

  describe '#sync_with_blockchain!' do
    let(:balance) { create(:balance, token: create(:lockup_token), wallet: create(:eth_wallet, _blockchain: :ethereum_rinkeby)) }
    subject { balance.sync_with_blockchain! }

    specify do
      expect(balance.token).to receive(:blockchain_balance).with(balance.wallet.address).and_return(999)
      expect(balance.token).to receive(:blockchain_locked_balance).with(balance.wallet.address).and_return(999)
      expect(balance.token).to receive(:blockchain_unlocked_balance).with(balance.wallet.address).and_return(999)

      expect(balance.base_unit_value).to eq 0
      expect(balance.base_unit_locked_value).to eq 0
      expect(balance.base_unit_unlocked_value).to eq 0

      is_expected.to be true
      balance.reload

      expect(balance.base_unit_value).to eq 999
      expect(balance.base_unit_locked_value).to eq 999
      expect(balance.base_unit_unlocked_value).to eq 999
    end

    context 'when values are not changed' do
      before do
        allow(balance.token).to receive(:blockchain_balance).with(balance.wallet.address).and_return(0)
        allow(balance.token).to receive(:blockchain_locked_balance).with(balance.wallet.address).and_return(0)
        allow(balance.token).to receive(:blockchain_unlocked_balance).with(balance.wallet.address).and_return(0)
      end

      it 'still updates timestamp' do
        expect { subject }.to change(balance, :updated_at)
      end
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

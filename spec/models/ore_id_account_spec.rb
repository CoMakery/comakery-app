require 'rails_helper'
require 'models/concerns/synchronisable_spec'

RSpec.describe OreIdAccount, type: :model do
  it_behaves_like 'synchronisable'

  before { allow_any_instance_of(described_class).to receive(:sync_allowed?).and_return(true) }

  subject { create(:ore_id) }
  it { is_expected.to belong_to(:account) }
  it { is_expected.to have_many(:wallets).dependent(:destroy) }
  it { is_expected.to define_enum_for(:state).with_values({ pending: 0, pending_manual: 1, unclaimed: 2, ok: 3 }) }
  specify { expect(subject.service).to be_an(OreIdService) }

  context 'after_create' do
    subject { described_class.new(account: create(:account), id: 99999) }

    it 'schedules a sync' do
      expect(OreIdSyncJob).to receive(:perform_later).with(subject.id)
      subject.save
    end

    context 'for pending_manual state' do
      subject { described_class.new(account: create(:account), id: 99999, state: :pending_manual) }

      it 'doesnt schedule a sync' do
        expect(OreIdSyncJob).not_to receive(:perform_later).with(subject.id)
        subject.save
      end
    end
  end

  context 'after_udpdate when account_name is updated' do
    subject { described_class.create(account: create(:account), id: 99999) }

    it 'schedules a wallet sync' do
      expect(OreIdWalletsSyncJob).to receive(:perform_later).with(subject.id)
      subject.update(account_name: 'dummy')
    end
  end

  describe '#sync_wallets' do
    context 'when wallet is not initialized locally' do
      before do
        subject.account.wallets.delete_all
      end

      it 'creates the wallet' do
        VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
          expect { subject.sync_wallets }.to change(subject.account.wallets, :count).by(1)
        end
      end
    end

    context 'when wallet is initialized locally' do
      before do
        create(:wallet, _blockchain: :algorand_test, source: :ore_id, account: subject.account, ore_id_account: subject, address: nil)
      end

      it 'sets the wallet address' do
        VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
          expect { subject.sync_wallets }.not_to change(subject.account.wallets, :count)
        end

        expect(subject.account.wallets.last.address).not_to be_nil
      end
    end
  end
end

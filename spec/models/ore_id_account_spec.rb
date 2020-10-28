require 'rails_helper'

RSpec.describe OreIdAccount, type: :model do
  subject { create(:ore_id) }
  it { is_expected.to belong_to(:account) }
  it { is_expected.to have_many(:wallets).dependent(:destroy) }
  specify { expect(subject.service).to be_an(OreIdService) }

  context 'after_create' do
    subject { described_class.new(account: create(:account), id: 99999) }

    it 'schedules jobs' do
      expect(OreIdSyncJob).to receive(:perform_later).with(subject.id)
      expect(OreIdWalletsSyncJob).to receive(:perform_later).with(subject.id)
      subject.save
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
        subject.account.wallets.find_by(source: :ore_id).update(address: nil, state: :pending)
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

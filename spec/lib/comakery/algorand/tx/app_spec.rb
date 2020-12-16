require 'rails_helper'

describe Comakery::Algorand::Tx::App do
  describe 'opt-in' do
    let(:app_id) { '13258116' }
    let!(:algorand_app_opt_in_tx) { build(:algorand_app_opt_in_tx, app_id: app_id) }

    before do
      VCR.use_cassette("Algorand/transcation/#{algorand_app_opt_in_tx.hash}") do
        algorand_app_opt_in_tx.data
      end
    end

    describe '#algorand' do
      it 'returns Comakery::Algorand' do
        expect(algorand_app_opt_in_tx.algorand).to be_a(Comakery::Algorand)
      end
    end

    describe '#data' do
      it 'returns all data' do
        expect(algorand_app_opt_in_tx.data).to be_a(Hash)
      end
    end

    describe '#transaction_data' do
      it 'returns transaction data' do
        expect(algorand_app_opt_in_tx.transaction_data).to be_a(Hash)
      end
    end

    describe '#confirmed_round' do
      it 'returns transaction confirmed round' do
        expect(algorand_app_opt_in_tx.confirmed_round).to eq(11105424)
      end
    end

    describe '#confirmed?' do
      context 'for unconfirmed transaction' do
        let!(:algorand_app_opt_in_tx) { build(:algorand_app_opt_in_tx, hash: 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA') }

        it 'returns false' do
          expect(algorand_app_opt_in_tx.confirmed?).to be false
        end
      end

      context 'for confirmed transaction' do
        it 'returns true' do
          expect(algorand_app_opt_in_tx.confirmed?).to be true
        end
      end
    end

    describe '#valid?' do
      let(:source) { 'IF3NLBLMC7A76RYCHZEIOJZULW7NDYQW4FHLJT3HZSU6GL6SEXLQLXFDXI' }
      let(:current_round) { 10661139 }
      let(:blockchain_transaction) do
        build(
          :blockchain_transaction_opt_in,
          token: create(:algorand_token),
          source: source,
          current_block: current_round,
          contract_address: app_id
        )
      end
      subject { algorand_app_opt_in_tx.valid?(blockchain_transaction) }

      context 'for incorrect source' do
        let(:source) { build(:algorand_address_2) }

        it { is_expected.to be false }
      end

      context 'ignore destination check' do
        let(:destination) { build(:algorand_address_1) }

        it { is_expected.to be true }
      end

      context 'for incorrect app_id' do
        let(:app_id) { '00000000' }

        it { is_expected.to be false }
      end

      context 'for valid data' do
        it { is_expected.to be true }
      end
    end
  end
end

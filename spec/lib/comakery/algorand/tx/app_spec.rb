require 'rails_helper'

describe Comakery::Algorand::Tx::App do
  let(:app_id) { '13258116' }
  let!(:algorand_app_tx) { build(:algorand_app_tx, app_id: app_id) }

  before do
    VCR.use_cassette("Algorand/transcation/#{algorand_app_tx.hash}") do
      algorand_app_tx.data
    end
  end

  describe '#algorand' do
    it 'returns Comakery::Algorand' do
      expect(algorand_app_tx.algorand).to be_a(Comakery::Algorand)
    end
  end

  describe '#transaction_app_id' do
  end

  describe '#transaction_app_accounts' do
  end

  describe '#transaction_app_args' do
  end

  describe '#transaction_on_completion' do
  end

  describe '#to_object' do
    subject { algorand_app_tx.to_object }

    specify { expect(subject['type']).to eq('appl') }
    specify { expect(subject['from']).to eq(algorand_app_tx.blockchain_transaction.source) }
    specify { expect(subject['to']).to be_nil }
    specify { expect(subject['amount']).to be_nil }
    specify { expect(subject['appIndex']).to eq(algorand_app_tx.app_id) }
    specify { expect(subject['appAccounts']).to eq([]) }
    specify { expect(subject['appArgs']).to eq([]) }
    specify { expect(subject['appOnComplete']).to eq(0) }
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

    subject { algorand_app_tx.valid? }

    context 'for incorrect app_id' do
      let(:app_id) { '00000000' }

      it { is_expected.to be false }
    end

    context 'for incorrect app_accounts' do
      let(:app_id) { '00000000' }

      it { is_expected.to be false }
    end

    context 'for incorrect app_args' do
      let(:app_id) { '00000000' }

      it { is_expected.to be false }
    end

    context 'for incorrect app_transaction_on_completion' do
      let(:app_id) { '00000000' }

      it { is_expected.to be false }
    end

    context 'for valid data' do
      it { is_expected.to be true }
    end
  end
end

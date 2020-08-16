require 'rails_helper'

describe Comakery::Dag::Tx do
  let(:network) { 'constellation_testnet' }
  let(:tx) { 'dummy_tx' }

  def stub_field(field, value)
    stub_constellation_request(network, tx, field => value)
  end

  describe '#data' do
    before do
      stub_field(0, 0)
    end

    it 'returns tx data' do
      expect(described_class.new(network, tx).data).to be_a(Hash)
    end
  end

  describe '#confirmed?' do
    context 'when tx hash is present' do
      before do
        stub_field('hash', tx)
      end

      it 'returns true' do
        expect(described_class.new(network, tx).confirmed?).to be_truthy
      end
    end

    context 'when tx hash is missing' do
      before do
        stub_field('hash', nil)
      end

      it 'returns false' do
        expect(described_class.new(network, tx).confirmed?).to be_falsey
      end
    end
  end

  describe '#valid_data?' do
    context 'for transaction with incorrect source' do
      let!(:dag_tx) { build(:dag_tx) }

      it 'returns false' do
        expect(dag_tx.valid_data?('dummy', dag_tx.destination, dag_tx.value)).to be_falsey
      end
    end

    context 'for transaction with incorrect destination' do
      let!(:dag_tx) { build(:dag_tx) }

      it 'returns false' do
        expect(dag_tx.valid_data?(dag_tx.source, 'dummy', dag_tx.value)).to be_falsey
      end
    end

    context 'for transaction with incorrect amount' do
      let!(:dag_tx) { build(:dag_tx) }

      it 'returns false' do
        expect(dag_tx.valid_data?(dag_tx.source, dag_tx.destination, 100)).to be_falsey
      end
    end

    context 'for correct transaction' do
      let!(:dag_tx) { build(:dag_tx) }

      it 'returns true' do
        expect(dag_tx.valid_data?(dag_tx.source, dag_tx.destination, dag_tx.value)).to be_truthy
      end
    end
  end

  describe '#valid?' do
    let!(:dag_tx) { build(:dag_tx) }
    let!(:blockchain_transaction) do
      build(
        :blockchain_transaction_dag,
        amount: dag_tx.value,
        source: dag_tx.source,
        destination: dag_tx.destination,
        token: create(:dag_token)
      )
    end

    context 'for correct transaction' do
      it 'returns true' do
        expect(dag_tx.valid?(blockchain_transaction)).to be_truthy
      end
    end

    context 'for incorrect transaction' do
      before do
        blockchain_transaction.amount = 100
      end

      it 'returns false' do
        expect(dag_tx.valid?(blockchain_transaction)).to be_falsey
      end
    end
  end

  %i[sender receiver amount fee snapshot_hash checkpoint_block].each do |method|
    context "when calling ##{method}" do
      before do
        stub_field(method.to_s.camelcase(:lower), 0)
      end

      it 'returns correct data' do
        expect(described_class.new(network, tx).send(method)).to eq(0)
      end
    end
  end
end

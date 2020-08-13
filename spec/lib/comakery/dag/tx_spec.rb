require 'rails_helper'

describe Comakery::Dag::Tx do
  let(:network) { 'constellation_testnet' }
  let(:explorer_var_name) { "BLOCK_EXPLORER_URL_#{network.upcase}" }
  let(:host) { (ENV[explorer_var_name] ||= 'dummyhost') && ENV[explorer_var_name] }
  let(:tx) { 'dummy_tx' }

  def stub_field(field, value)
    stub_request(:get, "https://#{host}/transactions/#{tx}").to_return(body: { field => value }.to_json)
  end

  describe '#data' do
    before do
      stub_field(0, 0)
    end

    it 'returns tx data' do
      expect(described_class.new(network, tx).data).to be_a(Hash)
    end
  end

  describe '#valid?' do
    context 'when tx hash is present' do
      before do
        stub_field('hash', tx)
      end

      it 'returns true' do
        expect(described_class.new(network, tx).valid?).to be_truthy
      end
    end

    context 'when tx hash is missing' do
      before do
        stub_field(nil, nil)
      end

      it 'returns false' do
        expect(described_class.new(network, tx).valid?).to be_falsey
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

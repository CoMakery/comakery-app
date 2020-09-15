require 'rails_helper'

describe Comakery::Constellation do
  context 'without block explorer env variable for the network' do
    let(:network) { 'constellation_dummynet' }

    it 'raises an error' do
      expect { described_class.new(network) }.to raise_error(RuntimeError, /Please Set/)
    end
  end

  describe '#tx' do
    let(:network) { 'constellation_test' }
    let(:tx) { 'dummy_tx' }

    before do
      stub_constellation_request(network, tx, {})
    end

    it 'returns transaction details by a given tx hash' do
      expect(described_class.new(network).tx(tx)).to be_a(Hash)
    end
  end
end

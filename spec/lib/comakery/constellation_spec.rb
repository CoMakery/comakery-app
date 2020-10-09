require 'rails_helper'

describe Comakery::Constellation do
  describe '#tx' do
    let(:host) { 'constellation_test' }
    let(:tx) { 'dummy_tx' }

    before do
      stub_constellation_request(host, tx, {})
    end

    it 'returns transaction details by a given tx hash' do
      expect(described_class.new(host).tx(tx)).to be_a(Hash)
    end
  end
end

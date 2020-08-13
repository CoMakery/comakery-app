require 'rails_helper'

describe Comakery::Constellation do
  context 'without block explorer env variable for the network' do
    let(:network) { 'constellation_dummynet' }

    it 'raises an error' do
      expect { described_class.new(network) }.to raise_error(RuntimeError, /Please Set/)
    end
  end

  describe '#tx' do
    let(:network) { 'constellation_testnet' }
    let(:explorer_var_name) { "BLOCK_EXPLORER_URL_#{network.upcase}" }
    let(:host) { (ENV[explorer_var_name] ||= 'dummyhost') && ENV[explorer_var_name] }
    let(:tx) { 'dummy_tx' }

    before do
      stub_request(:get, "https://#{host}/transactions/#{tx}").to_return(body: { 'isDummy' => true }.to_json)
    end

    it 'returns transaction details by a given tx hash' do
      expect(described_class.new(network).tx(tx)).to be_a(Hash)
    end
  end
end

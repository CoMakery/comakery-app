require 'rails_helper'

describe Comakery::Ethereum do
  before do
    allow(ENV).to receive(:[]) do |key|
      if key == 'ETHEREUM_BRIDGE'
        ethereum_bridge
      elsif key == 'ETHEREUM_BRIDGE_API_KEY'
        ethereum_bridge_api_key
      end
    end
  end

  let(:ethereum_bridge) { 'https://eth.example.com' }
  let(:ethereum_bridge_api_key) { 'abc123apikey' }

  describe '#token_contract' do
    it 'calls out to the expected server' do
      stub_request(:post, 'https://eth.example.com/project')
        .with(body: hash_including(maxSupply: 101,
                                   apiKey: 'abc123apikey'))
        .to_return(
          headers: { 'Content-Type': 'application/json' },
          body: { contractAddress: '0x9999999999999999999999999999999999999999' }.to_json
        )
      contractAddress = described_class.token_contract(maxSupply: 101)
      expect(contractAddress).to eq '0x9999999999999999999999999999999999999999'
    end

    describe 'with ETHEREUM_BRIDGE_API_KEY env var unset' do
      let(:ethereum_bridge_api_key) { nil }

      it 'requires that ETHEREUM_BRIDGE_API_KEY is set in ENV' do
        expect do
          described_class.token_contract(maxSupply: 101)
        end.to raise_error(/please set env var ETHEREUM_BRIDGE_API_KEY/)
      end
    end
  end

  describe '#token_issue' do
    it 'calls out to the expected server' do
      stub_request(:post, 'https://eth.example.com/token_issue')
        .with(body: hash_including(contractAddress: '0xcccccccccccccccccccccccccccccccccccccccc',
                                   recipient:       '0x2222222222222222222222222222222222222222',
                                   amount: 100,
                                   apiKey: 'abc123apikey'))
        .to_return(
          headers: { 'Content-Type': 'application/json' },
          body: { tx: '0x9999999999999999999999999999999999999999' }.to_json
        )
      transactionId = described_class.token_issue(
        contractAddress: '0xcccccccccccccccccccccccccccccccccccccccc',
        recipient: '0x2222222222222222222222222222222222222222',
        amount: 100
      )
      expect(transactionId).to eq '0x9999999999999999999999999999999999999999'
    end
  end

  # rubocop:disable RSpec/MessageSpies
  # rubocop:disable RSpec/AnyInstance
  describe 'token_symbol' do
    it 'get token symbol' do
      expect(described_class).to receive(:open).and_return(File.new(Rails.root.join('spec', 'fixtures', 'dummy.html')))
      allow_any_instance_of(NilClass).to receive(:next) { 'symbol = FCBB' }
      allow_any_instance_of(String).to receive(:text) { 'symbol = FCBB' }
      expect(described_class.token_symbol('0x2222222222222222222222222222222222222222')).to eq 'FCBB'
    end
  end
end

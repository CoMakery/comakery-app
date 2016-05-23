require 'rails_helper'

describe Comakery::Ethereum do
  # before { expect(ENV).to receive(:[]).with("ETHEREUM_BRIDGE").at_least(:once).and_return("https://eth.example.com") }
  # before { allow(ENV).to receive(:[]).with("ETHEREUM_BRIDGE").and_return("https://eth.example.com") }
  before do
    allow(ENV).to receive(:[]) do |key|
     if key == 'ETHEREUM_BRIDGE'
       "https://eth.example.com"
     end
    end
  end

  describe "#token_contract" do
    it "should call out to the expected server" do
      stub_request(:post, "https://eth.example.com/project")
        .with(body: hash_including({
          maxSupply: 101
        }))
        .to_return(
          headers: {'Content-Type': 'application/json'},
          body: {contractAddress: '0x9999999999999999999999999999999999999999'}.to_json
        )
      contractAddress = Comakery::Ethereum.token_contract(maxSupply: 101)
      expect(contractAddress).to eq '0x9999999999999999999999999999999999999999'
    end
  end

  describe "#token_issue" do

    it "should call out to the expected server" do
      stub_request(:post, "https://eth.example.com/token_issue")
        .with(body: hash_including({
          contractAddress: '0xcccccccccccccccccccccccccccccccccccccccc',
          recipient:       '0x2222222222222222222222222222222222222222',
          amount: 100,
        }))
        .to_return(
          headers: {'Content-Type': 'application/json'},
          body: {transactionId: '0x9999999999999999999999999999999999999999'}.to_json
        )
      transactionId = Comakery::Ethereum.token_issue(
        contractAddress: '0xcccccccccccccccccccccccccccccccccccccccc',
        recipient: '0x2222222222222222222222222222222222222222',
        amount: 100
      )
      expect(transactionId).to eq '0x9999999999999999999999999999999999999999'
    end
  end
end

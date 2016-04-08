require 'rails_helper'

describe Comakery::Ethereum do
  describe "#token_transfer" do
    let(:recipient_account) { create :account, ethereum_wallet: '0x2222222222222222222222222222222222222222' }
    let(:recipient_auth) { create :authentication, account: recipient_account }
    let(:project) { create :project, ethereum_contract_address: '0xcccccccccccccccccccccccccccccccccccccccc' }
    let(:award_type) { create :award_type, project: project, amount: 100 }
    let(:award) { create :award, award_type: award_type, authentication: recipient_auth }

    # before { expect(ENV).to receive(:[]).with("ETHEREUM_BRIDGE").at_least(:once).and_return("https://eth.example.com") }
    # before { allow(ENV).to receive(:[]).with("ETHEREUM_BRIDGE").and_return("https://eth.example.com") }
    before do
      allow(ENV).to receive(:[]) do |key|
       if key == 'ETHEREUM_BRIDGE'
         "https://eth.example.com"
       end
      end
    end

    it "should call out to the expected server" do
      stub_request(:post, "https://eth.example.com/token_transfer")
        .with(body: hash_including({
          contractAddress: '0xcccccccccccccccccccccccccccccccccccccccc',
          recipient:       '0x2222222222222222222222222222222222222222',
          amount: 100,
        }))
        .to_return(
          headers: {'Content-Type': 'application/json'},
          body: {transactionId: '0x9999999999999999999999999999999999999999'}.to_json
        )
      transactionId = Comakery::Ethereum.token_transfer(
        contractAddress: award.award_type.project.ethereum_contract_address,
        recipient: award.authentication.account.ethereum_wallet,
        amount: award.award_type.amount
      )
      expect(transactionId).to eq '0x9999999999999999999999999999999999999999'
    end
  end
end

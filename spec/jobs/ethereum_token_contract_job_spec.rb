require 'rails_helper'

describe EthereumTokenContractJob do

  let(:project) { create :project, maximum_coins: 101 }
  let(:job) { EthereumTokenContractJob.new }
  let(:address) { '0x'+'a'*40 }

  it "should do it" do
    expect(Comakery::Ethereum).to receive(:token_contract).with({maxSupply: 101}) { address }
    job.perform(project.id)
    expect(project.reload.ethereum_contract_address).to eq(address)
  end
end

require 'rails_helper'

describe EthereumTokenContractJob do

  let(:project) { create :project, maximum_coins: 101 }
  let(:job) { EthereumTokenContractJob.new }

  it "should do it" do
    expect(Comakery::Ethereum).to receive(:token_contract).with({maxSupply: 101})  { '0x123' }
    job.perform(project.id)
    expect(project.reload.ethereum_contract_address).to eq('0x123')
  end
end

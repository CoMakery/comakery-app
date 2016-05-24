require 'rails_helper'

describe EthereumTokenIssueJob do

  let(:contract_address) { '0x555' }
  let(:recipient_address) { '0x123' }
  let(:transaction_adddress) { '0x99999' }
  let(:project) { create :project, ethereum_contract_address: contract_address }
  let(:award) { create :award }
  let(:job) { EthereumTokenIssueJob.new }

  it do
    expect(Comakery::Ethereum).to receive(:token_issue).with({
        recipient: recipient_address,
        amount: 101,
        contract_address: contract_address
      }) { transaction_adddress }

    job.perform(award.id, project.id, {recipient: recipient_address, amount: 101})

    expect(award.reload.ethereum_transaction_address).to eq(transaction_adddress)
  end
end

require 'rails_helper'

describe EthereumTokenIssueJob do

  let(:contract_address) { '0x555' }
  let(:recipient_address) { '0x123' }
  let(:transaction_adddress) { '0x99999' }
  let(:project) { create :project, ethereum_contract_address: contract_address }
  let(:project_no_contract) { create :project, ethereum_contract_address: nil }
  let(:award) { create :award }
  let(:job) { EthereumTokenIssueJob.new }

  it 'should return an ethereum transaction address on completion' do
    expect(Comakery::Ethereum).to receive(:token_issue).with({
        recipient: recipient_address,
        amount: 101,
        contract_address: contract_address
      }) { transaction_adddress }

    job.perform(award.id, project.id, {recipient: recipient_address, amount: 101})

    expect(award.reload.ethereum_transaction_address).to eq(transaction_adddress)
  end

  it 'should raise if there is no ethereum contract yet' do
    expect do
      job.perform(award.id, project_no_contract.id, {recipient: recipient_address, amount: 101})
    end.to raise_error(ArgumentError, /no ethereum contract.*project.*#{project_no_contract.id}/i)
  end
end

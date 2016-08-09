require 'rails_helper'

describe EthereumTokenIssueJob do

  let(:contract_address) { '0x'+'a'*40 }
  let(:recipient_address) { '0x'+'b'*40 }
  let(:transaction_adddress) { '0x'+'c'*64 }
  let(:project) { create :project, ethereum_contract_address: contract_address }
  let(:award_type) { create :award_type, project: project }
  let(:award) { create :award, award_type: award_type, proof_id: '873!' }
  let(:job) { EthereumTokenIssueJob.new }

  it 'should return an ethereum transaction address on completion' do
    allow_any_instance_of(Award).to receive(:ethereum_ready?) { true }
    expect(Comakery::Ethereum).to receive(:token_issue).with({
        recipient: award.recipient_address,
        amount: award.award_type.amount,
        contractAddress: award.award_type.project.ethereum_contract_address,
        proofId: "873!"
      }) { transaction_adddress }

    job.perform(award.id)

    expect(award.reload.ethereum_transaction_address).to eq(transaction_adddress)
  end

  it 'should raise if there is no ethereum contract yet' do
    award.award_type.create_project(ethereum_contract_address: nil)
    expect do
      job.perform(award.id)
    end.to raise_error(ArgumentError, /cannot issue ethereum tokens from award ##{award.id}/i)
  end
end

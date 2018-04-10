require 'rails_helper'

describe EthereumTokenIssueJob do
  let(:contract_address) { '0x' + 'a' * 40 }
  let(:recipient_address) { '0x' + 'b' * 40 }
  let(:transaction_adddress) { '0x' + 'c' * 64 }
  let(:project) { create :project, ethereum_contract_address: contract_address }
  let(:award_type) { create :award_type, project: project, amount: 2 }
  let(:award) { create :award, award_type: award_type, proof_id: '873!' }
  let(:job) { described_class.new }

  it 'returns an ethereum transaction address on completion' do
    allow_any_instance_of(Award).to receive(:ethereum_issue_ready?) { true }
    expect(Comakery::Ethereum).to receive(:token_issue).with(recipient: award.recipient_address,
                                                             amount: award.award_type.amount,
                                                             contractAddress: award.project.ethereum_contract_address,
                                                             proofId: '873!') { transaction_adddress }

    job.perform(award.id)

    expect(award.reload.ethereum_transaction_address).to eq(transaction_adddress)
  end

  it 'does nothing if the project is not ethereum enabled' do
    allow_any_instance_of(Award).to receive(:ethereum_issue_ready?) { false }
    expect(Comakery::Ethereum).not_to receive(:token_issue)
    job.perform(award.id)
  end

  it 'raises if there is no ethereum contract yet' do
    allow_any_instance_of(Award).to receive(:ethereum_issue_ready?) { true }
    project.update_attribute(:ethereum_contract_address, nil)
    expect do
      job.perform(award.id)
    end.to raise_error(ArgumentError, /project ##{project.id} which has no ethereum contract address/i)
  end

  describe 'when award total amount calculation includes a quantity' do
    let(:award_type) { create :award_type, amount: 2, project: project }
    let(:issuer) { create :account }
    let(:authentication) { create :authentication }
    let(:award) { award_type.awards.create_with_quantity 1.5, issuer: issuer, account: authentication.account }

    before do
      allow_any_instance_of(Award).to receive(:ethereum_issue_ready?) { true }
    end

    it 'with the right test conditions' do
      expect(award.unit_amount).to eq(2)
      expect(award.total_amount).to eq(3)
    end

    it 'uses the award total_amount' do
      expect(Comakery::Ethereum).to receive(:token_issue).with(recipient: award.recipient_address,
                                                               amount: award.total_amount,
                                                               contractAddress: award.project.ethereum_contract_address,
                                                               proofId: award.proof_id) { transaction_adddress }

      job.perform(award.id)
    end
  end
end

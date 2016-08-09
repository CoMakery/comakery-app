require 'rails_helper'

describe CreateEthereumAwards do
  let!(:award) { create(:award) }
  let!(:award2) { create(:award) }
  let!(:award3) { create(:award) }

  describe 'with context.award' do
    it 'should trigger job, if ethereum contract and account present' do
      expect(award).to receive(:ethereum_ready?) { true }
      expect(EthereumTokenIssueJob).to receive(:perform_async).with(award.id)
      CreateEthereumAwards.call(award: award)
    end

    it 'should NOT trigger job, if ethereum contract or account NOT present' do
      expect(award).to receive(:ethereum_ready?) { false }
      expect(EthereumTokenIssueJob).not_to receive(:perform_async)
      CreateEthereumAwards.call(award: award)
    end
  end

  describe 'with context.awards' do
    it 'should trigger job, if ethereum contract and account present' do
      expect(award2).to receive(:ethereum_ready?) { true }
      expect(award3).to receive(:ethereum_ready?) { true }
      expect(EthereumTokenIssueJob).to receive(:perform_async).with(award2.id)
      expect(EthereumTokenIssueJob).to receive(:perform_async).with(award3.id)
      CreateEthereumAwards.call(awards: [award2, award3])
    end

    it 'should NOT trigger job, if ethereum contract or account NOT present' do
      expect(award2).to receive(:ethereum_ready?) { true }
      expect(award3).to receive(:ethereum_ready?) { false }
      expect(EthereumTokenIssueJob).to receive(:perform_async).with(award2.id)
      CreateEthereumAwards.call(awards: [award2, award3])
    end
  end

end

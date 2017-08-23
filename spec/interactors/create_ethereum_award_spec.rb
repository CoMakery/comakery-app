require 'rails_helper'

describe CreateEthereumAwards do
  let!(:award) { create(:award) }
  let!(:award2) { create(:award) }
  let!(:award3) { create(:award) }

  describe 'with context.award' do
    it 'triggers job, if ethereum contract and account present' do
      expect(award).to receive(:ethereum_issue_ready?) { true }
      expect(EthereumTokenIssueJob).to receive(:perform_async).with(award.id)
      described_class.call(award: award)
    end

    it 'NOTs trigger job, if ethereum contract or account NOT present' do
      expect(award).to receive(:ethereum_issue_ready?) { false }
      expect(EthereumTokenIssueJob).not_to receive(:perform_async)
      described_class.call(award: award)
    end
  end

  describe 'with context.awards' do
    it 'triggers job, if ethereum contract and account present' do
      expect(award2).to receive(:ethereum_issue_ready?) { true }
      expect(award3).to receive(:ethereum_issue_ready?) { true }
      expect(EthereumTokenIssueJob).to receive(:perform_async).with(award2.id)
      expect(EthereumTokenIssueJob).to receive(:perform_async).with(award3.id)
      described_class.call(awards: [award2, award3])
    end

    it 'NOTs trigger job, if ethereum contract or account NOT present' do
      expect(award2).to receive(:ethereum_issue_ready?) { true }
      expect(award3).to receive(:ethereum_issue_ready?) { false }
      expect(EthereumTokenIssueJob).to receive(:perform_async).with(award2.id)
      described_class.call(awards: [award2, award3])
    end
  end
end

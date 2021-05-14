require 'rails_helper'

RSpec.describe TransactionBatch, type: :model do
  it { is_expected.to have_one(:blockchain_transaction).dependent(:nullify) }
  it { is_expected.to have_many(:batch_transactables).dependent(:nullify) }
  it { is_expected.to have_many(:blockchain_transactables_awards).source(:blockchain_transactable) }
  it { is_expected.to have_many(:blockchain_transactables_account_token_records).source(:blockchain_transactable) }
  it { is_expected.to have_many(:blockchain_transactables_transfer_rules).source(:blockchain_transactable) }
  it { is_expected.to have_many(:blockchain_transactables_tokens).source(:blockchain_transactable) }
  it { is_expected.to have_many(:blockchain_transactables_token_opt_ins).source(:blockchain_transactable) }

  describe '#blockchain_transactables=' do
    let(:transaction_batch) { described_class.create }
    subject { transaction_batch.blockchain_transactables = transactable }

    context 'with a single transactable' do
      let(:transactable) { create(:transfer) }

      it 'creates batch transactable' do
        subject
        expect(transaction_batch.batch_transactables.count).to eq(1)
        expect(transaction_batch.blockchain_transactables_awards).to include(transactable)
      end
    end

    context 'with a relation including multiple transactables' do
      let!(:transfer1) { create(:transfer) }
      let!(:transfer2) { create(:transfer) }
      let(:transactable) { Award.all }

      it 'creates batch transactable' do
        subject
        expect(transaction_batch.batch_transactables.count).to eq(2)
        expect(transaction_batch.blockchain_transactables_awards).to include(transfer1)
        expect(transaction_batch.blockchain_transactables_awards).to include(transfer2)
      end
    end
  end
end

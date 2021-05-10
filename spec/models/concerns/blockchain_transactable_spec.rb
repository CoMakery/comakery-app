shared_examples 'blockchain_transactable' do
  it { is_expected.to have_many(:batch_transactables).dependent(:destroy) }
  it { is_expected.to have_many(:transaction_batches).dependent(:destroy) }
  it { is_expected.to have_many(:blockchain_transactions).dependent(:destroy) }
  it { is_expected.to have_one(:latest_batch_transactable).order('created_at: :desc').class_name('BatchTransactable').with_foreign_key(:blockchain_transactable_id) }
  it { is_expected.to have_one(:latest_transaction_batch).source(:transaction_batch) }
  it { is_expected.to have_one(:latest_blockchain_transaction).source(:blockchain_transaction) }

  describe '#latest_blockchain_transaction' do
    it 'returns record which belong to correct type and id' do
      transaction1 = create(:blockchain_transaction_transfer_rule)
      transaction2 = create(:blockchain_transaction_transfer_rule)
      account_token_record = create(:account_token_record, id: transaction1.blockchain_transactable.id)

      expect(transaction2.blockchain_transactable.latest_blockchain_transaction).to eq(transaction2)
      expect(account_token_record.latest_blockchain_transaction).to be_nil
    end
  end

  describe '#blockchain_transaction_class' do
    subject { described_class.new.blockchain_transaction_class }
    let(:classname) do
      if described_class == Token
        'BlockchainTransactionTokenFreeze'
      else
        "BlockchainTransaction#{described_class}"
      end
    end

    it { is_expected.to eq(classname.constantize) }
  end

  describe '#new_blockchain_transaction' do
    subject { described_class.new.new_blockchain_transaction({}) }
    let(:classname) do
      if described_class == Token
        'BlockchainTransactionTokenFreeze'
      else
        "BlockchainTransaction#{described_class}"
      end
    end

    it { is_expected.to be_a(classname.constantize) }
  end

  describe '#same_batch_transactables' do
    let(:transaction_batch) { TransactionBatch.create }
    let(:blockchain_transaction) { create(:blockchain_transaction_award_batch) }
    let(:transfer1) { blockchain_transaction.blockchain_transactables.first }
    let(:transfer2) { blockchain_transaction.blockchain_transactables.last }

    subject { transfer1.same_batch_transactables }

    it { is_expected.not_to include(transfer1) }
    it { is_expected.to include(transfer2) }
  end
end

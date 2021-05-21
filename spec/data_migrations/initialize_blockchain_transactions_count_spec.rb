require 'rails_helper'
require Rails.root.join('db/data_migrations/20210518174334_initialize_blockchain_transactions_count')

describe InitializeBlockchainTransactionsCount do
  subject { described_class.new.up }
  let!(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }

  it 'checks if the cached counter values are correct' do
    subject

    Award.find_each do |award|
      expect(award.blockchain_transactions_count).to eq(award.blockchain_transactions.size)
    end
  end
end

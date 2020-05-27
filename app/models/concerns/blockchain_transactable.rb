module BlockchainTransactable
  extend ActiveSupport::Concern

  included do
    has_many :blockchain_transactions, as: :blockchain_transactable
    has_one :latest_blockchain_transaction, -> { order created_at: :desc }, class_name: 'BlockchainTransaction', foreign_key: :blockchain_transactable_id
  end
end

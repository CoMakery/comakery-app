module BlockchainTransactable
  extend ActiveSupport::Concern

  included do
    has_many :blockchain_transactions, as: :blockchain_transactable
    has_one :latest_blockchain_transaction, -> { order created_at: :desc }, class_name: 'BlockchainTransaction', foreign_key: :blockchain_transactable_id

    # Return accepted awards matching at least one of the following conditions:
    # – Doesn't have any blockchain transactions yet
    # – Latest blockchain transaction state is "cancelled"
    # – (Optionally) Latest blockchain transaction state is "failed"
    # – Latest blockchain transaction state is "created" and transaction is created more than 10 minutes ago
    scope :ready_for_blockchain_transaction, lambda { |include_failed = false|
      q = joins(
        ''"
        LEFT JOIN blockchain_transactions
        ON blockchain_transactions.blockchain_transactable_id = #{table_name}.id
        AND blockchain_transactions.id = (
          SELECT MAX(id) FROM blockchain_transactions WHERE blockchain_transactions.blockchain_transactable_id = #{table_name}.id
        )
        "''
      )
          .distinct
          .where(
            ''"
            (blockchain_transactions.id IS NULL)
            OR (blockchain_transactions.status IN (2 #{include_failed ? ', 4' : nil}))
            OR (blockchain_transactions.status = 0 AND blockchain_transactions.created_at < :timestamp)
            "'',
            timestamp: 10.minutes.ago
          )

      if table_name == 'awards'
        q.accepted
      else
        q
      end
    }

    scope :ready_for_manual_blockchain_transaction, lambda {
      ready_for_blockchain_transaction(true)
    }
  end
end

module BlockchainTransactable
  extend ActiveSupport::Concern

  included do
    has_many :batch_transactables, dependent: :destroy, as: :blockchain_transactable
    has_many :transaction_batches, through: :batch_transactables
    has_many :blockchain_transactions, through: :transaction_batches, after_add: :update_transfer_blockchain_transactions_size, after_remove: :update_transfer_blockchain_transactions_size

    has_one :latest_batch_transactable, class_name: 'BatchTransactable', as: :blockchain_transactable, inverse_of: :blockchain_transactable, dependent: :destroy
    has_one :latest_transaction_batch, through: :latest_batch_transactable, source: :transaction_batch
    has_one :latest_blockchain_transaction, -> { order(created_at: :desc) }, through: :latest_transaction_batch, source: :blockchain_transaction

    # Return transactables matching at least one of the following conditions:
    # – Doesn't have any blockchain transactions yet
    # – Latest blockchain transaction state is "cancelled"
    # – (Optionally) Latest blockchain transaction state is "failed"
    # – Latest blockchain transaction state is "created" and transaction is created more than 10 minutes ago
    #
    # Model specific conditions:
    # - Award must be in `accepted` state
    # - AccountTokenRecord, TransferRule must be not in `synced` status
    scope :ready_for_blockchain_transaction, lambda { |include_failed = false|
      q = joins(sanitize_sql_array([
                                     ''"
        LEFT JOIN batch_transactables
          ON batch_transactables.id = (
            SELECT MAX(id) FROM batch_transactables
            WHERE batch_transactables.blockchain_transactable_id = #{table_name}.id
            AND batch_transactables.blockchain_transactable_type = '#{table_name.camelize.singularize}'
          )
        LEFT JOIN blockchain_transactions
          ON blockchain_transactions.transaction_batch_id = batch_transactables.transaction_batch_id
        "''
                                   ]))
          .distinct
          .where(
            ''"
            (blockchain_transactions.id IS NULL)
              OR (
                blockchain_transactions.status IN (2 #{include_failed ? ', 4' : nil})
              )
              OR (
                blockchain_transactions.status = 0
                  AND blockchain_transactions.created_at < :timestamp
              )
            "'',
            timestamp: 10.minutes.ago
          )
      q = q.accepted if table_name == 'awards'
      q = q.not_synced if table_name.in? %w[account_token_records transfer_rules]
      q = q.order("#{table_name}.prioritized_at DESC nulls last, #{table_name}.created_at ASC") if table_name.in? %w[account_token_records awards]
      q
    }

    scope :ready_for_batch_blockchain_transaction, lambda {
      return [] unless table_name == 'awards'

      ready_for_blockchain_transaction(false)
        .joins(:transfer_type).where.not('transfer_types.name': %w[mint burn])
        .joins(:token).where(%{
          (tokens.batch_contract_address IS NOT NULL)
            OR (
              tokens._token_type = 13
            )
        })
    }

    scope :ready_for_manual_blockchain_transaction, lambda {
      ready_for_blockchain_transaction(true)
    }

    scope :ready_for_hw_manual_blockchain_transaction, lambda {
      if table_name.in?(%w[awards account_token_records])
        ready_for_blockchain_transaction(true).where("#{table_name}.prioritized_at is not null")
      else
        self.class.none
      end
    }

    def update_transfer_blockchain_transactions_size(_blockchain_transaction)
      set_counter_cache
    end

    def set_counter_cache
      update!(blockchain_transactions_count: blockchain_transactions.size) if self.class == Award
    end

    def blockchain_transaction_class
      "BlockchainTransaction#{self.class}".constantize
    end

    def new_blockchain_transaction(params)
      blockchain_transaction_class.new(
        params.merge(
          blockchain_transactables: self
        )
      )
    end

    def same_batch_transactables
      latest_blockchain_transaction.blockchain_transactables.where.not(id: id)
    end

    # TODO: Handle all transaction statuses and cover with specs
    #
    # Logic below doesn't handle all possible cases properly
    def cancelable?
      case latest_blockchain_transaction&.status
      when 'created'
        !latest_blockchain_transaction&.waiting_in_created?
      when 'pending'
        false
      else
        true
      end
    end
  end
end

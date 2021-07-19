module BlockchainTransactable
  extend ActiveSupport::Concern

  included do
    has_many :batch_transactables, dependent: :destroy, as: :blockchain_transactable
    has_many :transaction_batches, through: :batch_transactables
    has_many :blockchain_transactions, through: :transaction_batches

    has_one :latest_batch_transactable, class_name: 'BatchTransactable', as: :blockchain_transactable, inverse_of: :blockchain_transactable, dependent: :destroy
    has_one :latest_transaction_batch, through: :latest_batch_transactable, source: :transaction_batch
    has_one :latest_blockchain_transaction, -> { order(created_at: :desc) }, through: :latest_transaction_batch, source: :blockchain_transaction

    scope :ready_for_batch_blockchain_transaction, lambda { |project|
      NextBlockchainTransactables.new(project: project, target: :manual, transactable_classes: [Award]).call
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

    def cancelable?
      case latest_blockchain_transaction&.status
      when 'created'
        !latest_blockchain_transaction&.waiting_in_created?
      when 'pending', 'cancelled', 'succeed'
        false
      when 'failed', nil
        true
      end
    end
  end
end

class NextBlockchainTransactables
  attr_reader :project, :transactable_classes, :target, :verified_accounts_only

  def initialize(project:, transactable_classes:, target:, verified_accounts_only: true)
    @project = project
    @transactable_classes = transactable_classes
    @target = target
    @verified_accounts_only = verified_accounts_only
  end

  def call
    transactions = []
    transactable_classes.each do |transactable_class|
      next unless hot_wallet_support?(transactable_class)

      if batch_support?(transactable_class)
        transactions = next_transactables_for(transactable_class, batch_size: project.transfer_batch_size)
        break if transactions.any?
      end

      transactions = next_transactables_for(transactable_class)
      break if transactions.any?
    end

    transactions
  end

  def next_transactables_for(transactable_class, batch_size: 1)
    joins_sql = <<~SQL
      LEFT JOIN batch_transactables
      ON batch_transactables.id = (
        SELECT MAX(id)
        FROM batch_transactables
        WHERE batch_transactables.blockchain_transactable_id = #{transactable_class.table_name}.id
        AND batch_transactables.blockchain_transactable_type = '#{transactable_class}'
      )
      LEFT JOIN blockchain_transactions
      ON blockchain_transactions.transaction_batch_id = batch_transactables.transaction_batch_id
    SQL

    where_sql = <<~SQL
      (blockchain_transactions.id IS NULL) OR
      (blockchain_transactions.status IN (:blockchain_transactions_cancelled_statuses)) OR
      (blockchain_transactions.status = :blockchain_transaction_created_status AND blockchain_transactions.created_at < :timestamp)
    SQL

    q = project
        .public_send(transactable_class.table_name)
        .joins(ApplicationRecord.sanitize_sql_array([joins_sql]))
        .distinct
        .where(
          where_sql,
          blockchain_transactions_cancelled_statuses: blockchain_transactions_cancelled_statuses,
          blockchain_transaction_created_status: BlockchainTransaction.statuses[:created],
          timestamp: 10.minutes.ago
        )

    if transactable_class == Award
      q = scopes_for_awards(q)
    elsif transactable_class == AccountTokenRecord
      q = scopes_for_account_token_records(q)
    elsif transactable_class == TransferRule
      q = scopes_for_transfer_rules(q)
    end

    q = filter_unverified_accounts(q, transactable_class) if verified_accounts_only
    q = filter_for_batch_tx(q) if batch_size > 1
    q.limit(batch_size)
  end

  private

    def blockchain_transactions_cancelled_statuses
      statuses = [BlockchainTransaction.statuses[:cancelled]]
      statuses << BlockchainTransaction.statuses[:failed] if include_failed?
      statuses
    end

    def scopes_for_awards(scope)
      scope = scope.accepted.order('awards.prioritized_at DESC nulls last, awards.created_at ASC')
      scope = scope.where('awards.prioritized_at is not null') if hot_wallet_manual?
      scope
    end

    def scopes_for_account_token_records(scope)
      scope = scope.not_synced.order('account_token_records.prioritized_at DESC nulls last, account_token_records.created_at ASC')
      scope = scope.where('account_token_records.prioritized_at is not null') if hot_wallet_manual?
      scope
    end

    def scopes_for_transfer_rules(scope)
      scope.not_synced
    end

    # TODO: Decide what we should consider as validated
    def filter_unverified_accounts(scope, transactable_class)
      verified_joins_sql = <<~SQL
        LEFT JOIN (
          select distinct on (account_id) *
          from verifications
          where passed = true
        ) as account_verified
        ON account_verified.account_id = #{transactable_class.table_name}.account_id
      SQL

      scope.joins(verified_joins_sql).where('account_verified.passed = true')
    end

    def filter_for_batch_tx(scope)
      scope
        .joins(:transfer_type).where.not('transfer_types.name': %w[mint burn])
        .joins(:token).where(<<~SQL, token_release_schedule: Token._token_types[:token_release_schedule])
          (tokens.batch_contract_address IS NOT NULL) OR
          (tokens._token_type = :token_release_schedule)
        SQL
    end

    def hot_wallet_manual?
      target[:for] == :hot_wallet && project.hot_wallet_manual_sending?
    end

    def hot_wallet_auto?
      target[:for] == :hot_wallet && project.hot_wallet_auto_sending?
    end

    def hot_wallet_support?(transactable_class)
      return true if target[:for] != :hot_wallet

      transactable_class != TransferRule
    end

    def batch_support?(transactable_class)
      transactable_class == Award && project.transfer_batch_size > 1
    end

    def include_failed?
      !hot_wallet_auto?
    end
end

class Api::V1::BlockchainTransactionsController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::AuthorizableByProjectKey
  include Api::V1::Concerns::AuthorizableByProjectPolicy
  include Api::V1::Concerns::RequiresAnAuthorization

  before_action :verify_hash, only: %i[update destroy]

  # POST /api/v1/projects/1/blockchain_transactions
  def create
    return head :no_content if creation_disabled?

    @transaction = transactable.new_blockchain_transaction(transaction_create_params) if transactable
    @transaction&.save

    if @transaction&.persisted?
      render 'show.json', status: :created
    else
      head :no_content
    end
  end

  # PATCH/PUT /api/v1/projects/1/blockchain_transactions/1
  def update
    if transaction.update(transaction_update_params)
      transaction.update_status(:pending)
      BlockchainJob::BlockchainTransactionSyncJob.perform_later(transaction)
    end

    render 'show.json', status: :ok
  end

  # DELETE /api/v1/projects/1/blockchain_transactions/1
  def destroy
    status = transaction_failed? ? :failed : :cancelled
    transaction.update_status(status, transaction_update_params[:status_message])

    render 'show.json', status: :ok
  end

  private

    def project
      @project ||= project_scope.find(params[:project_id])
    end

    def transaction
      @transaction ||= project.blockchain_transactions.find(params[:id])
    end

    def transactable_type
      @transactable_type ||= %w[
        account_token_records
        transfer_rules
        awards
      ].find do |type|
        type == params.dig(:body, :data, :blockchain_transactable_type)
      end
    end

    def transactable_id
      @transactable_id ||= params.dig(:body, :data, :blockchain_transactable_id)
    end

    def transactable
      @transactable ||= if transactable_type
        custom_transactable
      else
        default_transactable
      end
    end

    def custom_transactable
      collection = project.send(transactable_type)

      if transactable_id
        collection.ready_for_manual_blockchain_transaction.find(transactable_id)
      else
        collection.ready_for_blockchain_transaction.first
      end
    end

    def default_transactable
      project.account_token_records.ready_for_blockchain_transaction.first \
      || project.awards.ready_for_blockchain_transaction.first
    end

    def transaction_create_params
      params.fetch(:body, {}).fetch(:data, {}).fetch(:transaction, {}).permit(
        :source,
        :nonce
      )
    end

    def transaction_update_params
      params.fetch(:body, {}).fetch(:data, {}).fetch(:transaction, {}).permit(
        :tx_hash,
        :status_message
      )
    end

    def transaction_failed?
      params.fetch(:body, {}).fetch(:data, {}).fetch(:transaction, {}).permit(
        :failed
      ).present?
    end

    def verify_hash
      if transaction.tx_hash && transaction.tx_hash != transaction_update_params[:tx_hash]
        transaction.errors[:hash] << 'mismatch'
        @errors = transaction.errors

        render 'api/v1/error.json', status: :bad_request
      end
    end

    def hot_wallet_request?
      project.hot_wallet&.address == transaction_create_params[:source]
    end

    def hot_wallet_disabled?
      project.hot_wallet_disabled? && hot_wallet_request?
    end

    def creation_disabled?
      hot_wallet_disabled? || project.token.token_frozen?
    end
end

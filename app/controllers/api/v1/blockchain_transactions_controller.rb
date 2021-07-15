class Api::V1::BlockchainTransactionsController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::AuthorizableByProjectKey
  include Api::V1::Concerns::AuthorizableByProjectPolicy
  include Api::V1::Concerns::RequiresAnAuthorization

  # POST /api/v1/projects/1/blockchain_transactions
  def create
    return head :no_content if creation_disabled?

    if transactable.any?
      @transaction = transaction_class.new(transaction_create_params)
      @transaction.blockchain_transactables = transactable
      @transaction.save
    end

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
    project.update(hot_wallet_mode: :manual_sending) if switch_hw_to_manual_mode?

    render 'show.json', status: :ok
  end

  private

    def project
      @project ||= project_scope.find(params[:project_id])
    end

    def transaction
      @transaction ||= project.blockchain_transactions.find(params[:id])
    end

    def transactable_classes
      [AccountTokenRecord, Award]
    end

    def transaction_class
      t = transactable.respond_to?(:first) ? transactable.first : transactable
      t.blockchain_transaction_class
    end

    def transactable
      @transactable ||=
        NextBlockchainTransactables.new(
          project: project,
          transactable_classes: transactable_classes,
          target: { for: :hot_wallet },
          verified_accounts_only: false # TODO: change me to true then ready
        ).call
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

    def switch_hw_to_manual_mode?
      params_exists = params.dig(:body, :data, :transaction, :switch_hot_wallet_to_manual_mode).present?
      params_exists && project.hot_wallet_auto_sending?
    end

    def hot_wallet_request?
      @hot_wallet_request ||= project.hot_wallet&.address == transaction_create_params[:source]
    end

    def hot_wallet_disabled?
      project.hot_wallet_disabled? && hot_wallet_request?
    end

    def creation_disabled?
      hot_wallet_disabled? || project.token.token_frozen?
    end
end

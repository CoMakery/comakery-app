class Api::V1::BlockchainTransactionsController < Api::V1::ApiController
  include Api::V1::Concerns::RequiresAnAuthorization
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::AuthorizableByProjectKey
  include Api::V1::Concerns::AuthorizableByProjectPolicy

  before_action :verify_hash, only: %i[update destroy]

  # POST /api/v1/projects/1/blockchain_transactions
  def create
    if transactable
      @transaction = type.create(
        transaction_create_params.merge(
          blockchain_transactable: transactable
        )
      )
    end

    if @transaction&.persisted?
      render 'show.json', status: 201
    else
      @errors = { blockchain_transaction: 'No transactables available' }

      render 'api/v1/error.json', status: 204
    end
  end

  # PATCH/PUT /api/v1/projects/1/blockchain_transactions/1
  def update
    if transaction.update(transaction_update_params)
      transaction.update_status(:pending)
      Blockchain::BlockchainTransactionSyncJob.perform_later(transaction)
    end

    render 'show.json', status: 200
  end

  # DELETE /api/v1/projects/1/blockchain_transactions/1
  def destroy
    transaction.update_status(:cancelled, transaction_update_params[:status_message])

    render 'show.json', status: 200
  end

  private

    def project
      @project ||= project_scope.find(params[:project_id])
    end

    def transaction
      @transaction ||= project.blockchain_transactions.find(params[:id])
    end

    def type
      @type ||= case params.fetch(:body, {}).fetch(:data, {}).fetch(:blockchain_transactable_type, nil)
                when 'TransferRule'
                  BlockchainTransactionTransferRule
                when 'AccountTokenRecord'
                  BlockchainTransactionAccountTokenRecord
                else
                  BlockchainTransactionAward
      end
    end

    def transactables
      @transactables ||= case params.fetch(:body, {}).fetch(:data, {}).fetch(:blockchain_transactable_type, nil)
                         when 'TransferRule'
                           project.token.transfer_rules
                         when 'AccountTokenRecord'
                           project.token.account_token_records
                         else
                           project.awards
      end
    end

    def transactable
      @transactable ||= if params.fetch(:body, {}).fetch(:data, {}).fetch(:blockchain_transactable_id, nil)
        transactables.ready_for_manual_blockchain_transaction.find_by(id: params.fetch(:body, {}).fetch(:data, {}).fetch(:blockchain_transactable_id, nil))
      else
        transactables.ready_for_blockchain_transaction.first
      end
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

    def verify_hash
      if transaction.tx_hash && transaction.tx_hash != transaction_update_params[:tx_hash]
        transaction.errors[:hash] << 'mismatch'
        @errors = transaction.errors

        render 'api/v1/error.json', status: 400
      end
    end
end

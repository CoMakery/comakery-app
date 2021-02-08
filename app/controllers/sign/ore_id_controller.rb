class Sign::OreIdController < ApplicationController
  include OreIdCallbacks
  skip_after_action :verify_authorized, only: :receive, unless: :verify_errorless
  skip_after_action :verify_authorized, only: :new, unless: :transfer

  # POST /sign/ore_id/new
  def new
    # TODO: Add token admin role to policy token related tx
    authorize transfer, :pay? if transfer

    transactable = transfer || account_token_record || token

    transaction = BlockchainTransaction.create!(
      blockchain_transactable: transactable,
      source: current_account.address_for_blockchain(transfer.token._blockchain)
    )

    redirect_to sign_url(transaction)
  end

  # GET /sign/ore_id/receive
  def receive
    verify_errorless or return
    verify_received_account or return

    authorize received_transaction.blockchain_transactable, :pay?

    if received_transaction.update(tx_hash: params.require(:transaction_id), tx_raw: Base64.decode64(params.require(:signed_transaction)))
      received_transaction.update_status(:pending)
      BlockchainJob::BlockchainTransactionSyncJob.perform_later(received_transaction)
      flash[:notice] = 'Transaction Signed'
    else
      flash[:error] = received_transaction.errors.full_messages.join(', ')
    end

    # TODO: Cancel transaction on received_error if we somehow can get `state`
    #
    # received_transaction.update_status(:cancelled, received_error)

    redirect_to received_state['redirect_back_to']
  end

  private

    def transfer
      @transfer ||= policy_scope(Award).find(params.require(:transfer_id))
    end

    def account_token_record
      @account_token_record ||= AccountTokenRecord.find(params.require(:account_token_record_id))
    end

    def token
      @account_token_record ||= AccountTokenRecord.find(params.require(:token_id))
    end

    def received_transaction
      @received_transaction ||= BlockchainTransaction.find(received_state['transaction_id'])
    end
end

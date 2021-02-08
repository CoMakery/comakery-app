class Sign::OreIdController < ApplicationController
  include OreIdCallbacks
  skip_after_action :verify_authorized, only: :receive, unless: :verify_errorless

  # POST /sign/ore_id/new
  def new
    authorize transfer, :pay?

    transaction = BlockchainTransaction.create!(
      blockchain_transactable: transfer,
      source: current_account.address_for_blockchain(transfer.token._blockchain)
    )

    session[:ore_id_callback_url] = request.referer

    redirect_to sign_url(transaction)
  end

  # GET /sign/ore_id/receive
  def receive
    unless verify_errorless
      redirect_to session.delete(:ore_id_callback_url) || wallets_url

      return
    end

    unless verify_received_account
      head 401
      return
    end

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

    def received_transaction
      @received_transaction ||= BlockchainTransaction.find(received_state['transaction_id'])
    end
end

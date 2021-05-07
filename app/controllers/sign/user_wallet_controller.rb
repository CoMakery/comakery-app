class Sign::UserWalletController < ApplicationController
  include OreIdCallbacks
  skip_after_action :verify_authorized, only: %i[new receive]

  # POST /sing/user_wallet/new
  # GET /sign/user_wallet/new
  def new
    # TODO: Add token admin role to policy token related tx
    authorize new_transaction_transactable, :pay? if new_transaction_for_award?

    new_transaction.blockchain_transactables = new_transaction_transactable
    new_transaction.source = params[:source]
    new_transaction.save!

    render json: {
      tx: new_transaction.tx_raw,
      state: state(transaction_id: new_transaction.id)
    }
  end

  # GET /sign/user_wallet/receive
  def receive
    unless verify_errorless
      received_transaction.update_status(:cancelled, received_error&.truncate(100))
      flash[:error] = nil
      head 200
      return
    end

    unless verify_received_account
      head 401
      return
    end

    # TODO: Add token admin role to policy token related tx
    authorize received_transaction.blockchain_transactable, :pay? if received_transaction_for_award?

    if received_transaction.update(tx_hash: params.require(:transaction_id))
      received_transaction.update_status(:pending)
      BlockchainJob::BlockchainTransactionSyncJob.set(wait: 20).perform_later(received_transaction)
      head 200
    else
      head 400
    end
  end

  private

    def new_transaction # rubocop:todo Metrics/CyclomaticComplexity
      @new_transaction ||= if params[:transfer_id]
        BlockchainTransactionAward.new
      elsif params[:account_token_record_id]
        BlockchainTransactionAccountTokenRecord.new
      elsif params[:transfer_rule_id]
        BlockchainTransactionTransferRule.new
      elsif params[:token_id]
        if Token.find(params.require(:token_id)).token_frozen?
          BlockchainTransactionTokenUnfreeze.new
        else
          BlockchainTransactionTokenFreeze.new
        end
      end
    end

    def new_transaction_transactable
      @new_transaction_transactable ||= if params[:transfer_id]
        policy_scope(Award).find(params.require(:transfer_id))
      elsif params[:account_token_record_id]
        AccountTokenRecord.find(params.require(:account_token_record_id))
      elsif params[:transfer_rule_id]
        TransferRule.find(params.require(:transfer_rule_id))
      elsif params[:token_id]
        Token.find(params.require(:token_id))
      end
    end

    def new_transaction_for_award?
      new_transaction.is_a?(BlockchainTransactionAward)
    end

    def received_transaction_for_award?
      received_transaction.is_a?(BlockchainTransactionAward)
    end

    def received_transaction
      @received_transaction ||= BlockchainTransaction.find(received_state['transaction_id'])
    end
end

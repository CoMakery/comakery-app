class Sign::UserWalletController < ApplicationController
  include OreIdCallbacks
  skip_after_action :verify_authorized, only: %i[new receive]

  # POST /sing/user_wallet/new
  # GET /sign/user_wallet/new
  def new
    # TODO: Add token admin role to policy token related tx
    authorize new_transaction.blockchain_transactable, :pay? if new_transaction_for_award?

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
      BlockchainJob::BlockchainTransactionSyncJob.perform_later(received_transaction)
      flash[:notice] = 'Transaction Signed'
    else
      flash[:error] = received_transaction.errors.full_messages.join(', ')
    end

    head 200
  end

  private

    def new_transaction # rubocop:todo Metrics/CyclomaticComplexity
      @new_transaction ||= if params[:transfer_id]
        BlockchainTransactionAward.new(
          blockchain_transactable: policy_scope(Award).find(params.require(:transfer_id))
        )
      elsif params[:account_token_record_id]
        BlockchainTransactionAccountTokenRecord.new(
          blockchain_transactable: AccountTokenRecord.find(params.require(:account_token_record_id))
        )
      elsif params[:transfer_rule_id]
        BlockchainTransactionTransferRule.new(
          blockchain_transactable: TransferRule.find(params.require(:transfer_rule_id))
        )
      elsif params[:token_id]
        t = Token.find(params.require(:token_id))

        if t.token_frozen?
          BlockchainTransactionTokenUnfreeze.new(
            blockchain_transactable: t
          )
        else
          BlockchainTransactionTokenFreeze.new(
            blockchain_transactable: t
          )
        end
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

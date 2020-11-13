class Sign::OreIdController < ApplicationController
  include OreIdCallbacks
  skip_after_action :verify_authorized

  # GET /sign/ore_id/new
  def new
    transfer = Award.find(params.require(:transfer_id))
    source_wallet = current_account.wallets.find_by!(_blockchain: transfer.token._blockchain).address

    transaction = BlockchainTransactionAward.create!(
      blockchain_transactable: transfer,
      source: source_wallet,
      nonce: 1
    )

    redirect_to sign_url(transaction)
  end

  # GET /sign/ore_id/receive
  def receive
    if params[:error_code] || params[:error_message]
      error_message = "code: #{params[:error_code]}\nmessage: #{params[:error_message]}\nprocess id: #{params[:process_id]}"
      return render plain: error_message
    end
    raise OreIdCallbacks::NoStateError unless params[:state]

    head 401 unless current_account.id == received_state['account_id']

    # Process the transaction hash
    success_message = "signed transaction: #{Base64.decode64(params[:signed_transaction])}\ntransaction hash: #{params[:transaction_id]}\nstate: #{received_state}\nprocess id: #{params[:process_id]}"
    render plain: success_message
  end
end

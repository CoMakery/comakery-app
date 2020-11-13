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
    verify_errorless
    verify_received_account

    transaction = BlockchainTransactionAward.find(received_state['transaction_id'])
    transaction.tx_hash = params.require(:transaction_id)
    transaction.tx_raw = Base64.decode64(params.require(:signed_transaction))
    transaction.status = :pending
    transaction.save!

    redirect_to received_state['redirect_back_to']
  end
end

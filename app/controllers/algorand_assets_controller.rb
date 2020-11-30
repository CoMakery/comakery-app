class AlgorandAssetsController < ApplicationController
  include OreIdCallbacks

  skip_after_action :verify_policy_scoped

  helper_method :back_path

  # GET /algorand_assets
  def index
    @wallets = @current_account.wallets.ore_id
    @tokens = Token._token_type_asa

    redirect_to back_path, flash: { error: 'You don\'t have supported Algorand Wallets' } if @wallets.empty?
    redirect_to back_path, flash: { error: 'No supported Assets found' } if @tokens.empty?
  end

  def create
    @token_opt_in = TokenOptIn.find_or_initialize_by(wallet_id: params.require(:wallet_id), token_id: params.require(:token_id))
    authorize @token_opt_in, :create?

    @token_opt_in.status = :pending
    TokenOptIn.transaction do
      if @token_opt_in.save
        transaction = BlockchainTransactionOptIn.create!(blockchain_transactable: @token_opt_in)
        redirect_to sign_url(transaction)
      else
        redirect_to algorand_assets, notice: 'Problem with opt-in'
      end
    end
  end

  private

    def back_path
      wallets_path
    end
end

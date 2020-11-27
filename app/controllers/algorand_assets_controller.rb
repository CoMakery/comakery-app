class AlgorandAssetsController < ApplicationController
  skip_after_action :verify_authorized, :verify_policy_scoped

  helper_method :back_path

  # GET /algorand_assets
  def index
    @wallets = @current_account.wallets.ore_id
    @tokens = Token._token_type_asa

    redirect_to back_path, flash: { error: 'You don\'t have supported Algorand Wallets' } if @wallets.empty?
    redirect_to back_path, flash: { error: 'No supported Assets found' } if @tokens.empty?
  end

  def create

  end

  private

    def back_path
      wallets_path
    end
end

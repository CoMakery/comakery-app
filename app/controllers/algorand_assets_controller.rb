class AlgorandAssetsController < ApplicationController
  helper_method :back_path

  # GET /algorand_assets
  def index
    @tokens = policy_scope(Token)._token_type_asa
    @token_opt_ins = TokenOptIn.where(wallet: current_account.wallets.ore_id, token: @tokens)
  end

  private

    def back_path
      wallets_path
    end
end

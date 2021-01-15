class PrimariesController < ApplicationController
  before_action :set_wallet

  def create
    result = MakePrimaryWallet.call(account: current_account, wallet: @wallet)

    if result.success?
      flash[:notice] = 'The wallet is successfully set as Primary'
    else
      flash[:error] = result.error
    end

    redirect_to wallets_path
  end

  private

    def set_wallet
      @wallet = policy_scope(Wallet).find(params[:wallet_id])
    end
end

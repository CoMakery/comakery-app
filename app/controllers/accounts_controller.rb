class AccountsController < ApplicationController
  def update
    current_account.attributes = account_params
    authorize current_account
    current_account.save!
    redirect_to account_url, notice: "Ethereum address updated"
  end

  protected

  def account_params
    params.require(:account).permit(:ethereum_address)
  end
end
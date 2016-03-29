class AccountsController < ApplicationController
  def update
    @current_account = current_account
    @current_account.attributes = account_params
    authorize current_account

    unless @current_account.save
      @authentication = current_user.slack_auth
      @awards = @authentication.awards.includes(award_type: :project)
      flash[:error] = current_account.errors.full_messages.join(" ")
      render template: "authentications/show"
      return
    end

    redirect_to account_url, notice: "Ethereum address updated"
  end

  protected

  def account_params
    params.require(:account).permit(:ethereum_address)
  end
end
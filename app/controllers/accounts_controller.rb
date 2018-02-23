class AccountsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  skip_after_action :verify_authorized, :verify_policy_scoped, only: [:new, :create]

  def new
    @account = Account.new
  end

  def create
    @account = Account.new create_params
    if @account.save
      session[:account_id] = @account.id
      flash[:notice] = "Create account successfully"
      redirect_to root_path
    else
      render :new
    end
  end

  def update
    @current_account = current_account
    @current_account.attributes = account_params
    authorize current_account

    if @current_account.save
      CreateEthereumAwards.call(awards: @current_account.awards)
      redirect_to account_url, notice: 'Ethereum account updated. ' \
        'If this is an unused account the address will not be visible on the ' \
        'Ethereum blockchain until it is part of a transaction.'
    else
      @authentication = current_user.slack_auth
      @awards = @authentication.awards.includes(award_type: :project)
      flash[:error] = current_account.errors.full_messages.join(' ')
      render template: 'authentications/show'
    end
  end

  protected

  def account_params
    params.require(:account).permit(:ethereum_wallet)
  end

  def create_params
    params.require(:account).permit(:email, :password)
  end
end

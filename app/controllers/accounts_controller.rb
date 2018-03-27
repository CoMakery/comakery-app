class AccountsController < ApplicationController
  skip_before_action :require_login, only: %i[new create confirm confirm_authentication]
  skip_after_action :verify_authorized, :verify_policy_scoped, only: %i[new create confirm show]

  def new
    @account = Account.new
  end

  def create
    @account = Account.new account_params
    @account.email_confirm_token = SecureRandom.hex
    @account.password_required = true
    @account.name_required = true
    if @account.save
      session[:account_id] = @account.id
      flash[:notice] = 'Created account successfully. Please confirm your email before continuing.'
      UserMailer.confirm_email(@account).deliver
      redirect_to root_path
    else
      render :new
    end
  end

  def confirm
    account = Account.find_by email_confirm_token: params[:token]
    if account
      account.confirm!
      session[:account_id] = account.id
      flash[:notice] = 'Success! Your email is confirmed.'
    else
      flash[:error] = 'Invalid token'
    end
    redirect_to root_path
  end

  def confirm_authentication
    authentication = Authentication.find_by confirm_token: params[:token]
    if authentication
      authentication.confirm!
      session[:account_id] = authentication.account_id
      flash[:notice] = 'Success! Your email is confirmed.'
    else
      flash[:error] = 'Invalid token'
    end
    redirect_to root_path
  end

  def update
    @current_account = current_account
    authorize @current_account
    if @current_account.update(account_params.merge(name_required: true))
      CreateEthereumAwards.call(awards: @current_account.awards)
      redirect_to account_url, notice: 'Your account details have been updated.'
    else
      flash[:error] = current_account.errors.full_messages.join(' ')
      render :show
    end
  end

  protected

  def account_params
    params.require(:account).permit(:email, :ethereum_wallet, :first_name, :last_name, :nickname, :image, :password)
  end
end

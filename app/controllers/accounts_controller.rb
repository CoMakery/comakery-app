class AccountsController < ApplicationController
  skip_before_action :require_login, only: %i[new create confirm]

  def new
    @account = Account.new
  end

  def create
    @account = Account.new create_params
    @account.email_confirm_token = SecureRandom.hex
    @account.password_required = true
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

  def update
    @current_account = current_account
    if @current_account.update(account_params)
      CreateEthereumAwards.call(awards: @current_account.awards)
      redirect_to account_url, notice: 'Your account details have been updated.'
    else
      flash[:error] = current_account.errors.full_messages.join(' ')
      render :show
    end
  end

  protected

  def account_params
    params.require(:account).permit(:ethereum_wallet, :first_name, :last_name, :image)
  end

  def create_params
    params.require(:account).permit(:email, :password)
  end
end

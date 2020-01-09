class PasswordResetsController < ApplicationController
  skip_before_action :require_login
  skip_after_action :verify_authorized

  before_action :set_account, only: %i[edit update]

  layout 'legacy'

  def new; end

  def create
    @account = if @whitelabel_mission
      @whitelabel_mission.managed_accounts.find_by email: params[:email]
    else
      Account.find_by(email: params[:email], managed_mission_id: nil)
    end

    if @account
      @account.send_reset_password_request(@whitelabel_mission)
      flash[:notice] = 'please check your email for reset password instructions'
      redirect_to root_path
    else
      flash[:error] = 'Could not found account with given email'
      redirect_to new_password_reset_path
    end
  end

  def edit; end

  def update
    if @account.update permitted_param.merge(password_required: true)
      session[:account_id] = @account.id
      flash[:notice] = 'Successful reset password'
      redirect_to root_path
    else
      render :edit
    end
  end

  private

  def permitted_param
    params.require(:account).permit(:password)
  end

  def set_account
    @account = Account.find_by reset_password_token: params[:id] if params[:id].present?
    unless @account
      flash[:error] = 'Invalid reset password token'
      redirect_to root_path
    end
  end
end

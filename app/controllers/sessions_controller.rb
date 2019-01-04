class SessionsController < ApplicationController
  skip_before_action :require_login, :check_age
  skip_before_action :require_email_confirmation, only: %i[destroy]
  skip_after_action :verify_authorized, :verify_policy_scoped

  before_action :redirect_if_signed_in, only: %i[create sign_in]

  def oauth_failure
    flash[:error] = "Sorry, logging in failed... please try again, or email us at #{I18n.t('tech_support_email')}"
    redirect_to root_path
  end

  def create
    authentication = Authentication.find_or_create_by_omniauth(auth_hash)
    if authentication && authentication.confirmed?
      session[:account_id] = authentication.account_id
    elsif authentication
      UserMailer.confirm_authentication(authentication).deliver
      flash[:error] = 'Please check your email for confirmation instruction'
      @path = root_path
    else
      flash[:error] = 'Failed authentication - Auth hash is missing one or more required values'
      @path = root_path
    end
    redirect_to redirect_path
  end

  def sign_in
    @account = Account.find_by email: params[:email]
    begin
      if @account && @account.authenticate(params[:password])
        session[:account_id] = @account.id
        redirect_to redirect_path
      else
        flash[:error] = 'Invalid email or password'
        redirect_to new_session_path
      end
    rescue StandardError
      flash[:error] = 'Invalid email or password'
      redirect_to new_session_path
    end
  end

  def destroy
    session[:account_id] = nil
    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  def redirect_path
    token = session[:redeem]
    if token
      session[:redeem] = nil
      flash[:notice] = 'Please click the link in your email to claim your contributor token award!'
      root_path
    elsif @path
      @path
    else
      if current_account.new_award_notice
        process_new_award_notice(current_account)
      end
      root_path
    end
  end

  def process_new_award_notice(current_account)
    project = current_account.awards.last&.project
    if project&.coin_type_on_ethereum?
      if current_account.ethereum_wallet.blank?
        flash[:notice] = "Congratulations, you just claimed your award! Be sure to enter your Ethereum Address on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      else
        flash[:notice] = "Congratulations, you just claimed your award! Your Ethereum address is #{view_context.link_to current_account.ethereum_wallet, current_account.decorate.etherscan_address} you can change your Ethereum address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Ethereum tokens."
        current_account.update new_award_notice: false
      end
    elsif project&.coin_type_on_qtum?
      process_new_qtum_award_notice(current_account)
    elsif project&.coin_type_on_cardano?
      process_new_cardano_award_notice(current_account)
    end
  end

  def process_new_qtum_award_notice(current_account)
    if current_account.qtum_wallet.blank?
      flash[:notice] = "Congratulations, you just claimed your award! Be sure to enter your Qtum Address on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
    else
      flash[:notice] = "Congratulations, you just claimed your award! Your Qtum address is #{view_context.link_to current_account.qtum_wallet, current_account.decorate.qtum_wallet_url} you can change your Qtum address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Qtum tokens."
      current_account.update new_award_notice: false
    end
  end

  def process_new_cardano_award_notice(current_account)
    if current_account.cardano_wallet.blank?
      flash[:notice] = "Congratulations, you just claimed your award! Be sure to enter your Cardano Address on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
    else
      flash[:notice] = "Congratulations, you just claimed your award! Your Cardano address is #{view_context.link_to current_account.cardano_wallet, current_account.decorate.cardano_wallet_url} you can change your Cardano address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Cardano tokens."
      current_account.update new_award_notice: false
    end
  end
end

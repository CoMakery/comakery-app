class SessionsController < ApplicationController
  skip_before_action :require_login, :check_age
  skip_before_action :require_email_confirmation, only: %i[destroy]
  skip_after_action :verify_authorized, :verify_policy_scoped
  skip_before_action :require_build_profile

  before_action :redirect_if_signed_in, only: %i[create sign_in new]
  before_action :check_discord_oauth, only: %i[create]

  layout 'legacy'

  def oauth_failure
    flash[:error] = "Sorry, logging in failed... please try again, or email us at #{I18n.t('tech_support_email')}"
    redirect_to root_path
  end

  def create
    authentication = Authentication.find_or_create_by_omniauth(auth_hash)
    if authentication&.confirmed?
      session[:account_id] = authentication.account_id
    elsif authentication
      redirect_to_the_build_profile_accounts_page(authentication) && return
      UserMailer.with(whitelabel_mission: @whitelabel_mission).confirm_authentication(authentication).deliver
      flash[:error] = 'Please check your email for confirmation instruction'
      @path = my_tasks_path
    else
      flash[:error] = 'Failed authentication - Auth hash is missing one or more required values'
      @path = root_path
    end
    redirect_to redirect_path
  end

  def sign_in
    @account = if @whitelabel_mission
      @whitelabel_mission.managed_accounts.find_by email: params[:email]
    else
      Account.find_by(email: params[:email], managed_mission_id: nil)
    end

    if @account&.password_digest && @account&.authenticate(params[:password])
      session[:account_id] = @account.id
      redirect_to redirect_path
    else
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

    def check_discord_oauth
      if auth_hash['provider']&.include?('discord') && auth_hash['info'] && !auth_hash['info']['email']&.include?('@')
        flash[:error] = 'Please use Discord account with a valid email address'
        redirect_to new_session_path
      end
    end

    def redirect_path
      token = session[:redeem]
      if token
        session[:redeem] = nil
        flash[:notice] = 'Please click the link in your email to claim your contributor token award!'
        my_tasks_path
      elsif @path
        @path
      else
        process_new_award_notice if current_account.new_award_notice
        my_tasks_path
      end
    end

    def redirect_to_the_build_profile_accounts_page(authentication)
      unless authentication.account.email?
        session[:account_id] = authentication.account_id
        session[:authentication_id] = authentication.id
        redirect_to build_profile_accounts_path
        return true
      end
      false
    end

    def process_new_award_notice
      project = current_account.awards&.completed&.last&.project
      return nil unless project&.token&.coin_type?

      blockchain_name = Token::BLOCKCHAIN_NAMES[project.token.coin_type.to_sym]
      send("process_new_#{blockchain_name}_award_notice")
    end

    def process_new_ethereum_award_notice
      if current_account.ethereum_wallet.blank?
        flash[:notice] = "Congratulations, you just claimed your award! Be sure to enter your Ethereum Address on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      else
        flash[:notice] = "Congratulations, you just claimed your award! Your Ethereum address is #{view_context.link_to current_account.ethereum_wallet, current_account.decorate.etherscan_address} you can change your Ethereum address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Ethereum tokens."
        current_account.update new_award_notice: false
      end
    end

    def process_new_qtum_award_notice
      if current_account.qtum_wallet.blank?
        flash[:notice] = "Congratulations, you just claimed your award! Be sure to enter your Qtum Address on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      else
        flash[:notice] = "Congratulations, you just claimed your award! Your Qtum address is #{view_context.link_to current_account.qtum_wallet, current_account.decorate.qtum_wallet_url} you can change your Qtum address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Qtum tokens."
        current_account.update new_award_notice: false
      end
    end

    def process_new_cardano_award_notice
      if current_account.cardano_wallet.blank?
        flash[:notice] = "Congratulations, you just claimed your award! Be sure to enter your Cardano Address on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      else
        flash[:notice] = "Congratulations, you just claimed your award! Your Cardano address is #{view_context.link_to current_account.cardano_wallet, current_account.decorate.cardano_wallet_url} you can change your Cardano address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Cardano tokens."
        current_account.update new_award_notice: false
      end
    end

    def process_new_bitcoin_award_notice
      if current_account.bitcoin_wallet.blank?
        flash[:notice] = "Congratulations, you just claimed your award! Be sure to enter your Bitcoin Address on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      else
        flash[:notice] = "Congratulations, you just claimed your award! Your Bitcoin address is #{view_context.link_to current_account.bitcoin_wallet, current_account.decorate.bitcoin_wallet_url} you can change your Bitcoin address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Bitcoin tokens."
        current_account.update new_award_notice: false
      end
    end

    def process_new_eos_award_notice
      if current_account.eos_wallet.blank?
        flash[:notice] = "Congratulations, you just claimed your award! Be sure to enter your EOS account name on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      else
        flash[:notice] = "Congratulations, you just claimed your award! Your EOS account name is #{view_context.link_to current_account.eos_wallet, current_account.decorate.eos_wallet_url} you can change your EOS account name on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your EOS tokens."
        current_account.update new_award_notice: false
      end
    end

    def process_new_tezos_award_notice
      if current_account.tezos_wallet.blank?
        flash[:notice] = "Congratulations, you just claimed your award! Be sure to enter your Tezos Address on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      else
        flash[:notice] = "Congratulations, you just claimed your award! Your Tezos address is #{view_context.link_to current_account.tezos_wallet, current_account.decorate.tezos_wallet_url} you can change your Tezos address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Tezos tokens."
        current_account.update new_award_notice: false
      end
    end
end

class SessionsController < ApplicationController
  skip_before_action :require_login, :check_age
  skip_before_action :require_email_confirmation, only: %i[destroy]
  skip_after_action :verify_authorized, :verify_policy_scoped
  skip_before_action :require_build_profile

  before_action :redirect_if_signed_in, only: %i[create sign_in]
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
      return @path if @path
      return projects_path if @whitelabel_mission

      process_redeem_notice if session[:redeem]
      process_new_award_notice if current_account.new_award_notice

      my_tasks_path
    end

    def process_redeem_notice
      session[:redeem] = nil
      flash[:notice] = 'Please click the link in your email to claim your contributor token award!'
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

    def process_new_award_notice # rubocop:todo Metrics/CyclomaticComplexity
      project = current_account.awards&.completed&.last&.project
      return nil unless project&.token

      blockchain_name = project.token.blockchain.name
      addr = current_account.address_for_blockchain(project.token._blockchain)

      flash[:notice] = if addr.present?
        current_account.update(new_award_notice: false)
        "Congratulations, you just claimed your award! Your #{blockchain_name} address is #{addr}. You can change the address on your #{view_context.link_to('wallets page', wallets_path)}. The project owner can now issue your tokens."
      else
        "Congratulations, you just claimed your award! Be sure to enter your #{blockchain_name} address on your #{view_context.link_to('wallets page', wallets_path)} to receive your tokens."
      end
    end
end

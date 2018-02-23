class SessionsController < ApplicationController
  skip_before_action :require_login
  skip_after_action :verify_authorized, :verify_policy_scoped
  before_action :handle_beta_signup, only: :create

  def oauth_failure
    flash[:error] = "Sorry, logging in failed... please try again, or email us at #{I18n.t('tech_support_email')}"
    redirect_to root_path
  end

  def create
    begin
      @account = Authentication.find_or_create_from_auth_hash!(request.env['omniauth.auth'])
      session[:account_id] = @account.id
    rescue SlackAuthHash::MissingAuthParamException => e
      flash[:error] = "Failed authentication - #{e}"
    end
    redirect_to root_path
  end

  def sign_in
    @account = Account.find_by email: params[:email]
    if @account && @account.authenticate(params[:password])
      session[:account_id] = @account.id
      flash[:notice] = "Successful sign in"
      redirect_to root_path
    else
      flash[:error] = "Invalid email or password"
      redirect_to new_session_path
    end
  end

  def destroy
    session[:account_id] = nil
    redirect_to root_path
  end

  protected

  def handle_beta_signup
    beta_instances = ENV['BETA_SLACK_INSTANCE_WHITELIST']&.split(',')
    return if beta_instances.blank?
    slack_team_name = request.env.dig('omniauth.auth', 'info', 'team_domain')
    return oauth_failure unless slack_team_name
    return if beta_instances.include?(slack_team_name)
    slack_auth_hash = SlackAuthHash.new(request.env['omniauth.auth'])
    BetaSignup.create(email_address: slack_auth_hash.email_address,
                      name: slack_auth_hash.slack_real_name,
                      slack_instance: slack_team_name,
                      oauth_response: request.env['omniauth.auth'])
    redirect_to new_beta_signup_url(email_address: slack_auth_hash.email_address)
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end

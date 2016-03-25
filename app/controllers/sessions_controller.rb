class SessionsController < ApplicationController
  skip_before_filter :require_login
  skip_after_action :verify_authorized, :verify_policy_scoped
  before_filter :handle_beta_signup, only: :create

  def oauth_failure
    flash[:error] = "Sorry, logging in failed... please try again, or email us at dev@comakery.com"
    redirect_to root_path
  end

  def create
    begin
      d proc { request.env['omniauth.auth'] }
      @account = Authentication.find_or_create_from_auth_hash!(request.env['omniauth.auth'])
      session[:account_id] = @account.id
      redirect_to projects_url
    rescue SlackAuthHash::MissingAuthParamException
      flash['alert'] = "Failed authentication"
      redirect_to root_url
    end
  end

  def destroy
    session[:account_id] = nil
    redirect_to root_path
  end

  protected

  def handle_beta_signup
    beta_instances = ENV["BETA_SLACK_INSTANCE_WHITELIST"]&.split(",")
    return if beta_instances.blank?
    slack_team_name = request.env.dig('omniauth.auth', "info", "team")
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

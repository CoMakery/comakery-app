require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html
  layout 'raw'

  include Pundit
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # one HTTP auth password for the entire site
  if Rails.application.config.require_site_login
    http_basic_authenticate_with name: Rails.application.config.site_username,
                                 password: Rails.application.config.site_password
  end

  # require account logins for all pages by default
  # (public pages use skip_before_filter :require_login)
  before_action :require_login

  # called from before_filter :require_login
  def not_authenticated
    redirect_to root_path
  end

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  def not_found
    redirect_to '/404.html'
  end

  rescue_from Slack::Web::Api::Error do |exception|
    Rails.logger.error(exception.to_s)
    flash[:error] = 'Error talking to Slack, sorry!'
    session.delete(:account_id)
    redirect_to root_url
  end

  # called when a policy authorization fails
  rescue_from Pundit::NotAuthorizedError do |exception|
    Rails.logger.error(exception.to_s)
    redirect_to root_path
  end

  # use like: before_filter :require_admin
  def require_admin
    authorize :application, :admin?
  end

  def require_login
    not_authenticated unless session[:account_id]
  end

  def current_account
    @current_account ||= Account.find_by(id: session[:account_id])
  end
  helper_method :current_account
  alias current_user current_account
  helper_method :current_user

  def d(the_proc)
    return if Rails.env.test?
    unless the_proc.instance_of?(Proc)
      return STDERR.puts("d expected an instance of Proc, got #{the_proc.try(:inspect)}")
    end
    source = the_proc.try(:source).try(:match, /\s*proc { (.+) }\s*/).try(:[], 1)
    logger.debug "#{source} ===>>> " if source
    value = the_proc.call
    begin
      value = JSON.pretty_generate value, indent: '    '
      logger.debug "\n#{value}"
    rescue JSON::GeneratorError
      logger.debug value
    end
  end
end

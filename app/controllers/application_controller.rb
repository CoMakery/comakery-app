require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html
  # layout 'raw'
  include Pundit
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # require account logins for all pages by default
  # (public pages use skip_before_action :require_login)
  before_action :require_login, :require_email_confirmation, :check_age, :require_build_profile
  before_action :basic_auth

  def basic_auth
    return unless ENV.key?('BASIC_AUTH')

    basic_auth_name, basic_auth_password = ENV.fetch('BASIC_AUTH').split(':')

    return true unless basic_auth_name.present? && basic_auth_password.present?

    site_name = I18n.t('project_name')
    authenticate_or_request_with_http_basic(site_name) do |name, password|
      compare_all([name, basic_auth_name], [password, basic_auth_password])
    end
  end

  # called from before_filter :require_login
  def not_authenticated(msg = nil)
    respond_to do |format|
      format.html { redirect_to new_account_url, alert: msg }
      format.json { head :unauthorized }
    end
  rescue ActionController::UnknownFormat
    head :unauthorized
  end

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def not_found(e)
    if Rails.env.development?
      raise e
    else
      redirect_to '/404.html'
    end
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

  def require_login
    not_authenticated if session[:account_id].blank?
  end

  def require_email_confirmation
    if current_account && !current_account&.confirmed? && !current_account&.valid_and_underage?
      redirect_to root_path, flash: { warning: 'Please confirm your email address to continue' }
    end
  end

  def require_build_profile
    if current_account && (current_account.name_required = true) && !current_account.valid?
      @account = current_account
      @skip_validation = true
      flash[:error] = "Please complete your profile info for #{current_account.errors.keys.join(', ').humanize.titleize}"
      render 'accounts/build_profile'
    end
  end

  def redirect_if_signed_in
    return redirect_to root_path if current_account
  end

  def check_age
    if current_account && current_account.valid_and_underage? && controller_name != 'accounts'
      redirect_to build_profile_accounts_path, alert: 'Sorry, you must be 18 years or older to use this website'
    end
  end

  def current_account
    @current_account ||= Account.find_by(id: session[:account_id])
  end

  def error
    @error ||= nil
  end

  def notice
    @notice ||= nil
  end

  helper_method :current_account, :error, :notice
  alias current_user current_account
  helper_method :current_user

  def assign_project
    project = policy_scope(Project).find_by id: (params[:project_id] || params[:id])
    project = policy_scope(Project).find_by long_id: params[:project_id] unless project
    @project = project&.decorate if project&.can_be_access?(current_account)
    redirect_to root_path unless @project
  end

  # :nocov:

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

  def contributor_props(account)
    account.as_json(only: %i[id nickname first_name last_name]).merge(
      image_url: helpers.account_image_url(account, 68),
      specialty: Account.specialties[account.specialty]
    )
  end

  def project_props(project)
    contributors_number = project.contributors_by_award_amount.size
    award_data = GetContributorData.call(project: project).award_data
    chart_data = award_data[:contributions_summary_pie_chart].map { |award| award[:net_amount] }.sort { |a, b| b <=> a }

    project.as_json(only: %i[id title description]).merge(
      image_url: project.panoramic_image.present? ? Refile.attachment_url(project, :panoramic_image) : nil,
      square_url: project.square_image.present? ? Refile.attachment_url(project, :square_image) : nil,
      youtube_url: project.video_id,
      default_image_url: helpers.image_url('defaul_project.jpg'),
      owner: project.account.decorate.name,
      token_percentage: project.percent_awarded_pretty,
      maximum_tokens: project.maximum_tokens_pretty,
      awarded_tokens: project.total_awarded_pretty,
      team_leader: contributor_props(project.account),
      contributors_number: contributors_number,
      contributors: project.top_contributors.map { |contributor| contributor_props(contributor) },
      chart_data: chart_data
    )
  end

  def token_props(token)
    if token.present?
      token.as_json(only: %i[name symbol coin_type]).merge(
        image_url: token.logo_image.present? ? Refile.attachment_url(token, :logo_image, :fill, 25, 18) : nil,
        contract_url: token.ethereum_contract_explorer_url
      )
    end
  end

  private

  def compare_all(*pairs)
    pairs.map do |a, b|
      ActiveSupport::SecurityUtils.variable_size_secure_compare(a, b)
    end.reduce(:&)
  end
end

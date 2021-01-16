require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html
  # layout 'raw'
  include Pundit
  after_action :verify_authorized, except: :index # rubocop:todo Rails/LexicallyScopedActionFilter
  after_action :verify_policy_scoped, only: :index # rubocop:todo Rails/LexicallyScopedActionFilter
  after_action :set_whitelabel_cors

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # require account logins for all pages by default
  # (public pages use skip_before_action :require_login)
  before_action :set_whitelabel_mission
  before_action :require_login, :require_email_confirmation, :check_age, :require_build_profile
  before_action :basic_auth
  before_action :set_project_scope

  def basic_auth
    return unless ENV.key?('BASIC_AUTH')

    basic_auth_name, basic_auth_password = ENV.fetch('BASIC_AUTH').split(':')

    return true unless basic_auth_name.present? && basic_auth_password.present?

    site_name = I18n.t('project_name')
    authenticate_or_request_with_http_basic(site_name) do |name, password|
      compare_all([name, basic_auth_name], [password, basic_auth_password])
    end
  end

  def not_authenticated(msg = nil)
    session[:interested_in_project] = params[:project_id] if "#{controller_name}##{action_name}" == 'interests#create' && params[:project_id]

    respond_to do |format|
      format.html do
        session[:return_to] = request.url

        case "#{controller_name}##{action_name}"
        when 'awards#show', 'awards#index', 'award_types#index', 'accounts#show'
          redirect_to new_session_url, alert: msg
        else
          redirect_to new_account_url, alert: msg
        end
      end

      format.json { head :unauthorized }
    end
  rescue ActionController::UnknownFormat
    head :unauthorized
  end

  def redirect_back_to_session
    if current_account&.valid? && current_account&.confirmed? && session[:return_to]
      redirect_url = session[:return_to]
      session.delete(:return_to)
      redirect_to redirect_url
    end
  end

  def create_interest_from_session
    if current_account&.valid? && current_account&.confirmed? && session[:interested_in_project]
      current_account.interests.create(
        project: Project.find(session[:interested_in_project].to_i),
        specialty: current_account.specialty
      )

      session.delete(:interested_in_project)
    end
  end

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def not_found(e) # rubocop:todo Naming/MethodParameterName
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
    redirect_to show_account_path, flash: { warning: 'Please confirm your email address to continue' } if current_account && !current_account&.confirmed? && !current_account&.valid_and_underage?
  end

  def require_build_profile
    if current_account && (current_account.name_required = true) && !current_account.valid?
      @account = current_account
      @skip_validation = true
      flash[:error] = "Please complete your profile info for #{current_account.errors.keys.join(', ').humanize.titleize}"
      render 'accounts/build_profile', layout: 'legacy'
    end
  end

  def redirect_if_signed_in
    return redirect_to my_project_path if current_account
  end

  def check_age
    redirect_to build_profile_accounts_path, alert: 'Sorry, you must be 18 years or older to use this website' if current_account&.valid_and_underage? && controller_name != 'accounts'
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
    @project = @project_scope.find_by(id: params[:project_id] || params[:id])&.decorate
    return redirect_to '/404.html' unless @project
  end

  # rubocop:todo Metrics/PerceivedComplexity
  # rubocop:todo Metrics/AbcSize
  def task_to_props(task) # rubocop:todo Metrics/CyclomaticComplexity
    token_logo = GetImageVariantPath.call(
      attachment: task.project&.token&.logo_image,
      resize_to_fill: [100, 100]
    ).path
    task&.serializable_hash&.merge({
      description_html: Comakery::Markdown.to_html(task.description),
      requirements_html: Comakery::Markdown.to_html(task.requirements),
      specialty: task.specialty&.name,
      mission: {
        name: task.project&.mission&.name,
        url: task.project&.mission ? mission_path(task.project&.mission) : nil
      },
      token: {
        currency: task.project&.token&.symbol&.upcase,
        logo: token_logo
      },
      project: {
        id: task.project&.id,
        name: task.project&.title,
        legal_project_owner: task.project&.legal_project_owner,
        exclusive_contributions: task.project&.exclusive_contributions,
        confidentiality: task.project&.confidentiality,
        url: task.project && (task.project.unlisted? ? unlisted_project_path(task.project.long_id) : project_path(task.project)),
        channels: task.project.channels.includes(:team).map do |channel|
          {
            type: channel.provider,
            name: channel.name,
            url: channel.url,
            id: channel.id
          }
        end
      },
      issuer: {
        name: task.issuer&.decorate&.name,
        image: helpers.account_image_url(task.issuer, 100)
      },
      contributor: {
        name: task.account&.decorate&.name,
        image: helpers.account_image_url(task.account, 100),
        wallet_present: task.account&.decorate&.can_receive_awards?(task.project)
      },
      policies: {
        start: policy(task).start?,
        submit: policy(task).submit?,
        review: policy(task).review?,
        pay: policy(task).pay?
      },
      allowedToStart: true,
      experience_level_name: Award::EXPERIENCE_LEVELS.key(task.experience_level),
      image_url: Attachment::GetPath.call(attachment: task.image).path,
      submission_image_url: Attachment::GetPath.call(attachment: task.submission_image).path,
      payment_url: project_dashboard_transfers_path(task.project, q: { id_eq: task.id }),
      details_url: project_award_type_award_path(task.project, task.award_type, task),
      start_url: project_award_type_award_start_path(task.project, task.award_type, task),
      submit_url: project_award_type_award_submit_path(task.project, task.award_type, task),
      accept_url: project_award_type_award_accept_path(task.project, task.award_type, task),
      reject_url: project_award_type_award_reject_path(task.project, task.award_type, task),
      cancel_url: project_award_type_award_path(task.project, task.award_type, task),
      updated_at: helpers.time_ago_in_words(task.updated_at),
      expires_at: task.expires_at ? helpers.distance_of_time_in_words_to_now(task.expires_at) : nil,
      status: task.status.humanize.downcase
    })
  end
  # rubocop:enable Metrics/PerceivedComplexity

  # :nocov:

  def d(the_proc)
    return if Rails.env.test?
    return warn("d expected an instance of Proc, got #{the_proc.try(:inspect)}") unless the_proc.instance_of?(Proc)

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

  def current_domain
    [request.subdomains, request.domain].flatten.join('.')
  end

  def unavailable_for_whitelabel
    return unless @whitelabel_mission

    redirect_url = current_user ? projects_url : new_session_url
    redirect_to redirect_url
  end

  private

    def compare_all(*pairs)
      pairs.map do |a, b|
        ActiveSupport::SecurityUtils.secure_compare(a, b)
      end.reduce(:&)
    end

    def set_whitelabel_mission
      # rubocop:todo Naming/MemoizedInstanceVariableName
      @whitelabel_mission ||= Mission.where(whitelabel: true).find_by(whitelabel_domain: current_domain)
      # rubocop:enable Naming/MemoizedInstanceVariableName
    end

    def set_project_scope
      # rubocop:todo Naming/MemoizedInstanceVariableName
      @project_scope ||= @whitelabel_mission ? @whitelabel_mission.projects : Project.where(whitelabel: true)
      # rubocop:enable Naming/MemoizedInstanceVariableName
    end

    def set_whitelabel_cors
      if @whitelabel_mission
        headers['Access-Control-Allow-Origin'] = 'https://' + ENV['APP_HOST']
        headers['Access-Control-Allow-Credentials'] = 'true'
        headers['Access-Control-Allow-Methods'] = '*'
        headers['Access-Control-Allow-Headers'] = '*'
      end
    end
end

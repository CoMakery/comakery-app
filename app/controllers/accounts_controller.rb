require 'zip'

class AccountsController < ApplicationController
  include ProtectedWithRecaptcha
  include Rails::Pagination

  skip_before_action :require_login, only: %i[new create confirm confirm_authentication]
  skip_before_action :require_email_confirmation, only: %i[new create build_profile update_profile show update download_data confirm confirm_authentication]
  skip_before_action :require_build_profile, only: %i[build_profile update_profile confirm]
  skip_after_action :verify_authorized, :verify_policy_scoped, only: %i[index new create confirm confirm_authentication show download_data]
  before_action :redirect_if_signed_in, only: %i[new create]
  before_action :set_session_from_token, only: :new
  before_action :project_invite, only: %i[create update_profile]

  layout 'legacy', except: %i[index]

  def index
    authorize(current_user, :index?)

    @wallets = Wallet.with_mission(@whitelabel_mission&.id).not_hot_wallet.includes(account: :latest_verification)

    @wallets = paginate(@wallets)
  end

  def new
    @account = Account.new(email: params[:account_email])
  end

  def show # rubocop:todo Metrics/CyclomaticComplexity
    @projects = Project.left_outer_joins(:awards).where(awards: { account_id: current_account.id }).where.not(awards: { id: nil }).order(:title).group('projects.id').page(params[:project_page]).includes(:token).per(20)
    @awards = current_account.awards&.includes(:project, :token, :latest_blockchain_transaction)&.completed&.order(created_at: :desc)&.page(params[:award_page])&.per(20)
    @projects_count = @projects.total_count
    @awards_count = @awards.total_count

    @projects = @projects.map { |project| project_decorate(project, nil) }
    @awards = @awards.map do |award|
      next unless award.project

      award.as_json(only: %i[id]).merge(
        total_amount_pretty: award.decorate.total_amount_pretty,
        created_at: award.created_at.strftime('%b %d, %Y'),
        ethereum_transaction_explorer_url: award.decorate.ethereum_transaction_explorer_url,
        ethereum_transaction_address_short: award.decorate.ethereum_transaction_address_short,
        project: project_decorate(award.project, award)
      )
    end
    respond_to do |format|
      format.html
      format.json do
        render json: { awards: @awards, projects: @projects }
      end
    end
  end

  def create
    @account = Accounts::Initialize.call(
      whitelabel_mission: @whitelabel_mission,
      account_params: account_params
    ).account

    if recaptcha_valid?(model: @account, action: 'registration') && prepare_avatar(@account, account_params).valid? && @account.save
      session[:account_id] = @account.id

      if @project_invite.present?
        @account.confirm!
      else
        UserMailer.with(whitelabel_mission: @whitelabel_mission).confirm_email(@account).deliver
      end

      Project.where(auto_add_account: true).each { |project| project.add_account(@account) }

      redirect_to build_profile_accounts_path
    else
      @account.agreed_to_user_agreement = account_params[:agreed_to_user_agreement]

      render :new, status: :unprocessable_entity
    end
  end

  def build_profile
    redirect_to root_path if current_account.blank?
    @account = current_account
    @skip_validation = true # for the first time, don't show error message for metamask user's email field
    authorize @account
  end

  # TODO: Refactor complexity
  def update_profile # rubocop:todo Metrics/CyclomaticComplexity
    @account = current_account

    authorize @account

    old_email = @account.email

    if prepare_avatar(@account, account_params).valid? && @account.update(account_params.merge(name_required: true))
      authentication_id = session.delete(:authentication_id)
      if authentication_id && !Authentication.find_by(id: authentication_id).confirmed?
        session.delete(:account_id)
        @current_account = nil
        flash[:warning] = 'Please confirm your email address to continue'
      end

      if old_email != @account.email
        @account.set_email_confirm_token
        UserMailer.with(whitelabel_mission: @whitelabel_mission).confirm_email(@account).deliver
      end

      if @project_invite.present?
        Projects::ProjectRoles::CreateFromInvite.call(account: @account, project_invite: @project_invite)

        redirect_to project_path(@project_invite.invitable_id)
      else
        redirect_to my_tasks_path
      end
    else
      error_msg = @account.errors.full_messages.join(', ')
      flash[:error] = error_msg
      @skip_validation = false
      render :build_profile, status: :unprocessable_entity
    end
  end

  def confirm
    account = Account.find_by email_confirm_token: params[:token]
    if account
      account.confirm!
      session[:account_id] = account.id
      flash.clear
      if session[:redeem]
        flash[:notice] = 'Please click the link in your email to claim your contributor token award!'
        session[:redeem] = nil
      end
    else
      flash[:error] = 'Invalid token'
    end
    redirect_to my_tasks_path
  end

  def confirm_authentication
    authentication = Authentication.find_by confirm_token: params[:token]
    if authentication
      authentication.confirm!
      session[:account_id] = authentication.account_id
      flash.clear
      flash[:notice] = 'Success! Your email is confirmed.'
    else
      flash[:error] = 'Invalid token'
    end
    redirect_to my_tasks_path
  end

  def update # rubocop:todo Metrics/CyclomaticComplexity
    @current_account = current_account
    old_age = @current_account.age || 18
    authorize @current_account
    respond_to do |format|
      if prepare_avatar(@current_account, account_params).valid? && @current_account.update(account_params.merge(name_required: true))
        UserMailer.with(whitelabel_mission: @whitelabel_mission).confirm_email(@current_account).deliver if @current_account.email_confirm_token

        check_date(old_age) if old_age < 18
        format.html { redirect_to account_url, notice: 'Your account details have been updated.' }
        format.json do
          render json: {
            message: 'Your account details have been updated.',
            current_account: account_decorate(current_account)
          }, status: :ok
        end
      else
        error_msg = current_account.errors.full_messages.join(', ')
        format.html do
          flash[:error] = error_msg
          # Legacy code caused issue
          @projects = Project.left_outer_joins(:awards).where(awards: { account_id: current_account.id }).where.not(awards: { id: nil }).order(:title).group('projects.id').page(params[:project_page]).per(20)
          @awards = current_account.awards&.completed&.order(created_at: :desc)&.page(params[:award_page])&.per(20)
          render :show, status: :unprocessable_entity
        end
        format.json do
          errors = current_account.errors.messages
          errors.each { |key, value| errors[key] = value.to_sentence }
          render json: { message: error_msg, errors: errors }, status: :unprocessable_entity
        end
      end
    end
  end

  def download_data
    respond_to do |format|
      format.zip do
        compressed_filestream = Zip::OutputStream.write_buffer do |zos|
          zos.put_next_entry 'profile.csv'
          zos.print current_account.to_csv
          zos.put_next_entry 'awards.csv'
          zos.print current_account.awards_csv
        end
        compressed_filestream.rewind
        send_data compressed_filestream.read, filename: 'my-data.zip'
      end
    end
  end

  protected

    def account_params
      result = params.require(:account).permit(
        :agreed_to_user_agreement,
        :email,
        :ethereum_auth_address,
        :first_name,
        :last_name,
        :nickname,
        :country,
        :date_of_birth,
        :image,
        :password,
        :specialty_id,
        :occupation,
        :linkedin_url,
        :github_url,
        :dribble_url,
        :behance_url
      )

      if result[:date_of_birth].present?
        begin
          result[:date_of_birth] = DateTime.strptime(result[:date_of_birth], '%m/%d/%Y')
        rescue StandardError => e
          Rails.logger.error(e)
          result[:date_of_birth] = nil
        end
      end

      result
    end

    def check_date(old_age)
      UserMailer.with(whitelabel_mission: @whitelabel_mission).underage_alert(@current_account, old_age).deliver_now if @current_account.age >= 18
    end

    def project_decorate(project, award = nil)
      project.as_json(only: %i[id title token_symbol]).merge(
        awards_path: project_dashboard_transfers_path(project, q: { account_id_eq: current_account.id }),
        award_path: project_dashboard_transfers_path(project, q: { id_eq: award&.id }),
        total_awarded: project.decorate.total_awarded_to_user(current_account),
        token: project.token ? project.token.serializable_hash : {}
      )
    end

    def account_decorate(account)
      account.as_json(only: %i[email first_name last_name nickname date_of_birth country ethereum_auth_address]).merge(
        image_url: helpers.account_image_url(account, 190)
      )
    end

    def prepare_avatar(account, params)
      ImagePreparer.new(account, params, image: { resize: '190x190!' })
    end

    def set_session_from_token
      project_invite = ProjectInvite.find_by(token: params[:token])

      session[:project_invite_id] = project_invite.id if project_invite.present? && !project_invite.accepted?
    end

    def project_invite
      return if session[:project_invite_id].blank?

      @project_invite ||= ProjectInvite.find(session[:project_invite_id])
    end
end

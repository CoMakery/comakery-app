require 'zip'
class AccountsController < ApplicationController
  skip_before_action :require_login, only: %i[new create confirm confirm_authentication]
  skip_before_action :require_email_confirmation, only: %i[new create build_profile update_profile show update download_data confirm confirm_authentication]
  skip_before_action :require_build_profile, only: %i[build_profile update_profile]
  skip_after_action :verify_authorized, :verify_policy_scoped, only: %i[new create confirm confirm_authentication show download_data]

  before_action :redirect_if_signed_in, only: %i[new create]

  def new
    @account = Account.new(email: params[:account_email])
  end

  def show
    @projects = Project.left_outer_joins(:awards).where(awards: { account_id: current_account.id }).where.not(awards: { id: nil }).order(:title).group('projects.id').page(params[:project_page]).per(20)
    @awards = current_account.awards.order(created_at: :desc).page(params[:award_page]).per(20)
    @projects_count = @projects.total_count
    @awards_count = @awards.total_count

    @projects = @projects.map { |project| project_decorate(project) }
    @awards = @awards.map do |award|
      award.as_json(only: %i[id]).merge(
        total_amount_pretty: award.decorate.total_amount_pretty,
        created_at: award.created_at.strftime('%b %d, %Y'),
        ethereum_transaction_explorer_url: award.decorate.ethereum_transaction_explorer_url,
        ethereum_transaction_address_short: award.decorate.ethereum_transaction_address_short,
        project: project_decorate(award.project)
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
    @account = Account.new account_params
    @account.email_confirm_token = SecureRandom.hex
    @account.password_required = true
    @account.name_required = false
    @account.agreement_required = true
    @account.agreed_to_user_agreement = if params[:account][:agreed_to_user_agreement] == '0'
      nil
    else
      Date.current
    end
    if @account.save
      session[:account_id] = @account.id
      UserMailer.confirm_email(@account).deliver
      redirect_to build_profile_accounts_path
    else
      @account.agreed_to_user_agreement = params[:account][:agreed_to_user_agreement]
      render :new
    end
  end

  def build_profile
    redirect_to root_path if current_account.blank?
    @account = current_account
    @skip_validation = true # for the first time, don't show error message for metamask user's email field
    authorize @account
  end

  def update_profile
    @account = current_account
    authorize @account

    if @account.update(account_params.merge(name_required: true))
      redirect_to root_path, notice: 'Thank you for signing up. Now, let us know what projects you are interested in.'
    else
      error_msg = @account.errors.full_messages.join(', ')
      flash[:error] = error_msg
      @skip_validation = false
      render :build_profile
    end
  end

  def confirm
    account = Account.find_by email_confirm_token: params[:token]
    if account
      account.confirm!
      session[:account_id] = account.id
      flash[:notice] = 'Success! Your email is confirmed.'
      if session[:redeem]
        flash[:notice] = 'Please click the link in your email to claim your contributor token award!'
        session[:redeem] = nil
      end
    else
      flash[:error] = 'Invalid token'
    end
    redirect_to root_path
  end

  def confirm_authentication
    authentication = Authentication.find_by confirm_token: params[:token]
    if authentication
      authentication.confirm!
      session[:account_id] = authentication.account_id
      flash[:notice] = 'Success! Your email is confirmed.'
    else
      flash[:error] = 'Invalid token'
    end
    redirect_to root_path
  end

  def update
    @current_account = current_account
    old_age = @current_account.age || 18
    authorize @current_account
    respond_to do |format|
      if @current_account.update(account_params.merge(name_required: true))
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
          @awards = current_account.awards.order(created_at: :desc).page(params[:award_page]).per(20)
          render :show
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
    result = params.require(:account).permit(:email, :ethereum_wallet, :qtum_wallet, :cardano_wallet, :bitcoin_wallet, :eos_wallet, :first_name, :last_name, :nickname, :country, :date_of_birth, :image, :password, :specialty, :occupation, :linkedin_url, :github_url, :dribble_url, :behance_url)
    result[:date_of_birth] = DateTime.strptime(result[:date_of_birth], '%m/%d/%Y') if result[:date_of_birth].present?
    result
  end

  def check_date(old_age)
    if @current_account.age >= 18
      UserMailer.underage_alert(@current_account, old_age).deliver_now
    end
  end

  def project_decorate(project)
    project.as_json(only: %i[id title token_symbol ethereum_contract_address]).merge(
      awards_path: project_awards_path(project.show_id, mine: true),
      total_awarded: project.decorate.total_awarded_to_user(current_account),
      ethereum_contract_explorer_url: project.decorate.ethereum_contract_explorer_url
    )
  end

  def account_decorate(account)
    account.as_json(only: %i[email first_name last_name nickname date_of_birth country qtum_wallet ethereum_wallet cardano_wallet bitcoin_wallet eos_wallet]).merge(
      etherscan_address: account.decorate.etherscan_address,
      qtum_address: account.decorate.qtum_wallet_url,
      cardano_address: account.decorate.cardano_wallet_url,
      bitcoin_address: account.decorate.bitcoin_wallet_url,
      eos_address: account.decorate.eos_wallet_url,
      image_url: account.image.present? ? Refile.attachment_url(account, :image, :fill, 190, 190) : nil
    )
  end
end

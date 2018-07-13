require 'zip'
class AccountsController < ApplicationController
  skip_before_action :require_login, only: %i[new create confirm confirm_authentication]
  skip_after_action :verify_authorized, :verify_policy_scoped, only: %i[new create confirm confirm_authentication show download_data]

  def new
    @account = Account.new
  end

  def create
    @account = Account.new account_params
    @account.email_confirm_token = SecureRandom.hex
    @account.password_required = true
    @account.name_required = true
    if @account.save
      session[:account_id] = @account.id
      flash[:notice] = 'Created account successfully. Please confirm your email before continuing.'
      UserMailer.confirm_email(@account).deliver
      redirect_to root_path
    else
      render :new
    end
  end

  def confirm
    account = Account.find_by email_confirm_token: params[:token]
    if account
      account.confirm!
      session[:account_id] = account.id
      flash[:notice] = 'Success! Your email is confirmed.'
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
    if @current_account.update(account_params.merge(name_required: true))
      check_date(old_age) if old_age < 18
      redirect_to account_url, notice: 'Your account details have been updated.'
    else
      flash[:error] = current_account.errors.full_messages.join(' ')
      render :show
    end
  end

  def download_data
    respond_to do |format|
      format.html
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
    result = params.require(:account).permit(:email, :ethereum_wallet, :first_name, :last_name, :nickname, :country, :date_of_birth, :image, :password)
    result[:date_of_birth] = DateTime.strptime(result[:date_of_birth], '%m/%d/%Y') if result[:date_of_birth].present?
    result
  end

  def check_date(old_age)
    if @current_account.age >= 18
      UserMailer.underage_alert(@current_account, old_age).deliver_now
    end
  end
end

class AccountsController < ApplicationController
  skip_before_action :require_login, only: %i[new create confirm]
  skip_after_action :verify_authorized, :verify_policy_scoped, only: %i[new create confirm show receive_award]

  def new
    @account = Account.new
  end

  def create
    @account = Account.new create_params
    @account.email_confirm_token = SecureRandom.hex
    @account.password_required = true
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

  def update
    @current_account = current_account
    authorize @current_account

    if @current_account.update(account_params)
      CreateEthereumAwards.call(awards: @current_account.awards)
      redirect_to account_url, notice: 'Your account details have been updated.'
    else
      flash[:error] = current_account.errors.full_messages.join(' ')
      render :show
    end
  end

  def receive_award
    award_link = AwardLink.find_by token: params[:token]
    if award_link
      owner = award_link.owner
      award_params = { award_type_id: award_link.award_type_id, quantity: award_link.quantity, description: award_link.description }
      result = AwardSlackUser.call(project: award_link.award_type.project,
                                   slack_user_id: current_account.slack_auth.slack_user_id,
                                   issuer: owner,
                                   award_params: award_params)
      if result.success?
        award = result.award
        award.save
        CreateEthereumAwards.call(award: award)
        owner.send_award_notifications(award: award)
        flash[:notice] = 'Successfully receive award to your account.'
        redirect_to account_path
      end
    else
      flash[:error] = 'Invalid award token.'
      redirect_to root_path
    end
  end

  protected

  def account_params
    params.require(:account).permit(:ethereum_wallet, :first_name, :last_name, :image)
  end

  def create_params
    params.require(:account).permit(:email, :password)
  end
end

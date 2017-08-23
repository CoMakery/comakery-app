class BetaSignupsController < ApplicationController
  skip_before_action :require_login
  skip_after_action :verify_authorized

  def new
    @beta_signup = BetaSignup.new(email_address: params[:email_address])
  end

  def create
    if params[:commit] == Views::BetaSignups::New::OPT_IN_SUBMIT_BUTTON_TEXT
      @beta_signup = BetaSignup.where(email_address: beta_signup_params[:email_address]).last
      @beta_signup ||= BetaSignup.new

      unless @beta_signup.update(beta_signup_params.merge(opt_in: true))
        render :new
        flash[:errors] = @beta_signup.errors.full_messages.join(' ')
        return
      end
      redirect_to root_url, notice: 'You have been added to the beta waiting list. Invite more people from your slack to sign up for the beta. We will be inviting the slack teams with the most beta list signups first!'
    else
      redirect_to root_url, notice: 'You have not been added to the beta waiting list. Check back to see new public CoMakery projects!'
    end
  end

  def beta_signup_params
    params.require(:beta_signup).permit(:email_address)
  end
end

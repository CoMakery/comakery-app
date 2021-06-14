class UserMailer < ApplicationMailer
  def confirm_email(account)
    @url = confirm_email_url(token: account.email_confirm_token, host: @host)
    mail to: account.email, subject: "Let's Make It Official. Confirm Your Email."
  end

  def confirm_authentication(authentication)
    @authentication = authentication
    @provider = @authentication.provider
    @url = confirm_authentication_url(token: authentication.confirm_token, host: @host)
    mail to: authentication.account.email, subject: 'Confirm your account email'
  end

  def send_award_notifications(award)
    @award = award
    @owner = award.project.account.decorate.name
    @url = confirm_award_url(token: award.confirm_token, host: @host)
    mail to: award.email, subject: "Incoming #{award.project.title} Tokens - Now Confirm Your Award!"
  end

  def incoming_award_notifications(award)
    @award = award
    @owner = award.project.account.decorate.name
    @url = account_url(token: award.confirm_token, host: @host)
    mail to: award.account.email, subject: "Incoming #{@award.project.title} Tokens - See Your Award!"
  end

  def reset_password(account)
    @url = edit_password_reset_url(account.reset_password_token, host: @host)
    mail to: account.email, subject: 'Reset your password'
  end

  def underage_alert(account, old_age)
    @account = account
    @old_age = old_age
    mail to: 'support@comakery.com', subject: '[Support] Potential Underage User'
  end
end

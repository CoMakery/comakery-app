class UserMailer < ApplicationMailer
  def confirm_email(account)
    host = ActionMailer::Base.asset_host
    @url = "#{host}/accounts/confirm/#{account.email_confirm_token}"
    mail to: account.email, subject: 'Confirm your account email'
  end

  def send_award_notifications(award); end

  def reset_password(account)
    host = ActionMailer::Base.asset_host
    @url = "#{host}/password_resets/#{account.reset_password_token}/edit"
    mail to: account.email, subject: 'Confirm your account email'
  end
end

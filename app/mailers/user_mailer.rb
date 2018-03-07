class UserMailer < ApplicationMailer
  def confirm_email(account)
    @url = confirm_email_url(token: account.email_confirm_token)
    mail to: account.email, subject: 'Confirm your account email'
  end

  def send_award_notifications(award); end

  def reset_password(account)
    @url = edit_password_reset_url(account.reset_password_token)
    mail to: account.email, subject: 'Confirm your account email'
  end
end

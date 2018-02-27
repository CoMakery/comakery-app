class UserMailer < ApplicationMailer
  def confirm_email(account)
    host = ActionMailer::Base.asset_host
    @url = "#{host}/accounts/confirm/#{account.email_confirm_token}"
    mail to: account.email, subject: 'Confirm your account email'
  end

  def send_award_notifications(email, message)
    @message = message
    mail to: email, subject: 'you have received an award from Comakery'
  end
end

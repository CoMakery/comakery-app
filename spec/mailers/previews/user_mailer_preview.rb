class UserMailerPreview < ActionMailer::Preview
  def confirm_email
    UserMailer.confirm_email(Account.where.not(email_confirm_token: nil).sample)
  end

  def confirm_authentication
    UserMailer.confirm_authentication(Authentication.where.not(confirm_token: nil).sample)
  end

  def send_award_notifications
    UserMailer.send_award_notifications(Award.where.not(confirm_token: nil).sample)
  end

  def incoming_award_notifications
    UserMailer.incoming_award_notifications(Award.all.sample)
  end

  def reset_password
    UserMailer.reset_password(Account.where.not(reset_password_token: nil).sample)
  end
end

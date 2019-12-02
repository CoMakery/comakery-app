class UserMailerWhitelabelPreview < ActionMailer::Preview
  def confirm_email
    UserMailer.with(whitelabel_mission: Mission.where(whitelabel: true).sample).confirm_email(Account.where.not(email_confirm_token: nil).sample)
  end

  def confirm_authentication
    UserMailer.with(whitelabel_mission: Mission.where(whitelabel: true).sample).confirm_authentication(Authentication.where.not(confirm_token: nil).sample)
  end

  def send_award_notifications
    UserMailer.with(whitelabel_mission: Mission.where(whitelabel: true).sample).send_award_notifications(Award.where.not(confirm_token: nil).sample)
  end

  def incoming_award_notifications
    UserMailer.with(whitelabel_mission: Mission.where(whitelabel: true).sample).incoming_award_notifications(Award.all.sample)
  end

  def reset_password
    UserMailer.with(whitelabel_mission: Mission.where(whitelabel: true).sample).reset_password(Account.where.not(reset_password_token: nil).sample)
  end
end

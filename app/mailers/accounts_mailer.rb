class AccountsMailer < ActionMailer::Base
  default from: I18n.t('contact_email')
  layout 'email'

  def reset_password_email(account)
    @account = account
    @url = edit_password_reset_url(account.reset_password_token)
    mail(to: account.email, subject: "Change your #{I18n.t('project_name')} password")
  end
end
